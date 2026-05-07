# To-Do App — Simple 3-Tier on Azure
# Web VMSS (Nginx) → App VMSS (FastAPI) → Azure Database for PostgreSQL

## Architecture

```
Internet (port 80)
       │
  [Azure Load Balancer — Web Tier]
       │
  ┌────┴────┐
  │  vm-web-1│  vm-web-2  ← Web VMSS (Nginx)
  └────┬────┘
       │ proxy /api/* → port 8000
  [Azure Internal Load Balancer — App Tier]
       │
  ┌────┴────┐
  │  vm-app-1│  vm-app-2  ← App VMSS (FastAPI)
  └────┬────┘
       │ port 5432 (SSL)
  [Azure Database for PostgreSQL]
        tododb
```

## Files

```
todo-app/
├── web-tier/
│   ├── nginx.conf     ← Nginx: serves index.html, proxies /api/* to App VMSS
│   └── index.html     ← Single-page To-Do frontend (vanilla JS, no build needed)
├── app-tier/
│   ├── main.py        ← FastAPI: all CRUD in one file, uses asyncpg
│   └── requirements.txt
└── db-tier/
    └── init.sql       ← One table: todos(id, title, done, created_at)
```

---

## STEP 1 — Azure Database for PostgreSQL

### 1.1 Create the server (Azure Portal)
- Go to: **Azure Portal → Create a resource → Azure Database for PostgreSQL Flexible Server**
- Server name:  `todo-pg-server`
- Admin user:   `todoadmin`
- Password:     `YourStrongPass123!`
- Version:      16
- SKU:          Burstable B1ms (fine for testing)
- **Networking**: Add your App VMSS subnet to the firewall rules

### 1.2 Create the database and table

```bash
# From Azure Cloud Shell or any machine with psql installed
psql "host=todo-pg-server.postgres.database.azure.com \
      port=5432 dbname=postgres user=todoadmin sslmode=require"

# Inside psql:
CREATE DATABASE tododb;
\c tododb
\i init.sql     -- or paste contents of db-tier/init.sql
\q
```

---

## STEP 2 — App VMSS (FastAPI)

Run these commands on EACH App VM instance (or bake into a custom image / cloud-init script).

### 2.1 SSH into App VM

```bash
ssh -i ~/.ssh/your_key.pem azureuser@<app-vm-public-ip>
```

### 2.2 Install Python and dependencies

```bash
sudo apt update && sudo apt install -y python3.12 python3.12-venv python3.12-dev build-essential

mkdir ~/todo && cd ~/todo
python3.12 -m venv venv
source venv/bin/activate
```

### 2.3 Upload and install app files

```bash
# From your LOCAL machine:
scp -i ~/.ssh/your_key.pem \
  todo-app/app-tier/main.py \
  todo-app/app-tier/requirements.txt \
  azureuser@<app-vm-ip>:/home/azureuser/todo/

# Back on the App VM:
cd ~/todo && source venv/bin/activate
pip install -r requirements.txt
```

### 2.4 Create environment file

```bash
cat > ~/todo/.env << 'EOF'
DB_HOST=todo-pg-server.postgres.database.azure.com
DB_PORT=5432
DB_NAME=tododb
DB_USER=todoadmin
DB_PASSWORD=YourStrongPass123!
DB_SSL=require
EOF
chmod 600 ~/todo/.env
```

### 2.5 Create systemd service

```bash
sudo tee /etc/systemd/system/todo-app.service << 'EOF'
[Unit]
Description=Todo FastAPI App
After=network.target

[Service]
User=azureuser
WorkingDirectory=/home/azureuser/todo
EnvironmentFile=/home/azureuser/todo/.env
ExecStart=/home/azureuser/todo/venv/bin/uvicorn main:app \
          --host 0.0.0.0 --port 8000 --workers 2 --proxy-headers
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable todo-app
sudo systemctl start todo-app
```

### 2.6 Verify

```bash
sudo systemctl status todo-app
curl http://localhost:8000/health
# {"status":"healthy","tier":"app","db":"ok"}

curl http://localhost:8000/api/todos
# [...list of todos from PostgreSQL...]
```

### 2.7 Azure NSG for App VMSS

```
Inbound rule: Allow TCP 8000 from Web VMSS subnet only
Inbound rule: Allow TCP 22  from your IP only (admin)
```

---

## STEP 3 — Web VMSS (Nginx)

Run on EACH Web VM instance.

### 3.1 SSH into Web VM

```bash
ssh -i ~/.ssh/your_key.pem azureuser@<web-vm-public-ip>
```

### 3.2 Install Nginx

```bash
sudo apt update && sudo apt install -y nginx
```

### 3.3 Edit nginx.conf — update App VMSS private IPs

Open `web-tier/nginx.conf` on your local machine and update the upstream block:

```nginx
upstream app_backend {
    least_conn;
    server <app-vm-1-private-ip>:8000 max_fails=3 fail_timeout=30s;
    server <app-vm-2-private-ip>:8000 max_fails=3 fail_timeout=30s;
    keepalive 16;
}
```

### 3.4 Upload files and install

```bash
# From your LOCAL machine:
scp -i ~/.ssh/your_key.pem \
  todo-app/web-tier/nginx.conf \
  todo-app/web-tier/index.html \
  azureuser@<web-vm-ip>:/home/azureuser/

# On the Web VM:
sudo cp /home/azureuser/nginx.conf /etc/nginx/nginx.conf
sudo cp /home/azureuser/index.html /usr/share/nginx/html/index.html

sudo nginx -t
# nginx: configuration file /etc/nginx/nginx.conf syntax is ok

sudo systemctl reload nginx
sudo systemctl enable nginx
```

### 3.5 Verify

```bash
curl http://localhost/health
# {"status":"ok","tier":"web"}

curl http://localhost/api/todos
# [...proxied from FastAPI → PostgreSQL...]
```

### 3.6 Azure NSG for Web VMSS

```
Inbound rule: Allow TCP 80  from Any (public)
Inbound rule: Allow TCP 22  from your IP only (admin)
```

---

## STEP 4 — End-to-End Test

```bash
# From your local machine — replace with your Web LB public IP
WEB_IP=<azure-load-balancer-public-ip>

# Health checks
curl http://$WEB_IP/health

# List todos (should return 4 seed items)
curl http://$WEB_IP/api/todos

# Create a todo
curl -X POST http://$WEB_IP/api/todos \
  -H "Content-Type: application/json" \
  -d '{"title": "My first todo"}'

# Open browser
open http://$WEB_IP
```

---

## Azure Load Balancer Health Probe Settings

| Tier | Protocol | Port | Path    | Interval |
|------|----------|------|---------|----------|
| Web  | HTTP     | 80   | /health | 15s      |
| App  | HTTP     | 8000 | /health | 15s      |

---

## Redeploy after a code change

```bash
# App code change:
scp -i ~/.ssh/your_key.pem todo-app/app-tier/main.py azureuser@<app-vm-ip>:~/todo/
ssh -i ~/.ssh/your_key.pem azureuser@<app-vm-ip> "sudo systemctl restart todo-app"

# Frontend change:
scp -i ~/.ssh/your_key.pem todo-app/web-tier/index.html \
  azureuser@<web-vm-ip>:/usr/share/nginx/html/index.html
# (no nginx restart needed for static file changes)
```