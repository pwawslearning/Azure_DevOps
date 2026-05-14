# 🏗️ Three-Tier Architecture on Azure with Terraform & Azure DevOps CI/CD

![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Azure](https://img.shields.io/badge/Azure-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)
![Azure DevOps](https://img.shields.io/badge/Azure_DevOps-0078D4?style=for-the-badge&logo=azuredevops&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)

## 📌 Project Overview

This project provisions a production-grade **Three-Tier Architecture** on Microsoft Azure using **Terraform** with self-authored, reusable modules. The entire infrastructure lifecycle is automated through two dedicated **Azure DevOps pipelines** — a **Build Pipeline** for provisioning and a **Destroy Pipeline** for teardown — ensuring consistent, repeatable, and auditable infrastructure delivery.

The architecture spans **two availability zones** for high availability, with a Python-based application backend, PostgreSQL databases, and a secure networking design using Private DNS Zones, Azure Bastion, and Key Vault.

---

## 🏛️ Architecture Overview

![Architecture Diagram](./images/Azure%203Tier%20Architecture.png)


| Tier | Resource | Details |
|------|----------|---------|
| **Presentation** | Azure Application Gateway | Public entry point; routes HTTP/80 to web VMSS |
| **Web** | VM Scale Sets (`web_vmss01`, `web_vmss02`) | Nginx web servers across 2 subnets (multi-AZ) |
| **Application** | VM Scale Sets (`app_vmss01`, `app_vmss02`) | Python app backend; listening on HTTP/8080 |
| **Data** | PostgreSQL (`db_sub01`, `db_sub02`) | Managed database across 2 subnets; TCP/5432 |
| **Networking** | VNet, Subnets, Backend LB, Private DNS Zones | Segmented network with internal load balancing |
| **Security** | Azure Key Vault, Azure Bastion | Secret management & secure VM access (no public IPs) |
| **State** | Azure Storage Account | Terraform remote state backend with locking |

---

## ⚙️ Tech Stack

| Tool / Service | Purpose |
|----------------|---------|
| **Terraform** | Infrastructure as Code |
| **Custom Terraform Modules** | 6 self-authored reusable modules for each resource type |
| **YAML config files** | Per-component variable injection via pipeline |
| **Azure DevOps Pipelines** | Build & Destroy pipeline automation |
| **GitHub** | Source code repository (integrated with Azure DevOps) |
| **Python** | Application backend (`main.py`, `todo/`) |
| **Nginx** | Web tier serving (configured via `nginx.cf`) |
| **PostgreSQL** | Relational database (initialised via `init.sql`) |

---

## 📁 Project Structure

```
Project_2/
├── appgw.tf                    # Application Gateway configuration
├── backend_lb.tf               # Internal Backend Load Balancer
├── compute.tf                  # VM Scale Sets (web & app tiers)
├── database.tf                 # PostgreSQL database resources
├── keyvault.tf                 # Azure Key Vault
├── locals.tf                   # Local value definitions
├── network.tf                  # VNet, Subnets, DNS zones, Bastion
├── remote_backend.tf           # Remote state backend (Azure Storage)
├── terraform.tfvars            # Root variable values
├── variables.tf                # Input variable declarations
│
├── config/                     # YAML-based variable configs
│   ├── backend.yaml
│   ├── database.yaml
│   ├── frontend.yaml
│   ├── network.yaml
│   └── vmss.yaml
│
├── modules/                    # Self-authored reusable Terraform modules
│   ├── Network/                # VNet, Subnets, NSGs
│   ├── Compute/                # VM Scale Sets
│   ├── application_gateway/    # Azure Application Gateway
│   ├── load_balancer/          # Internal Backend Load Balancer
│   ├── database/               # PostgreSQL Database
│   └── keyvault/               # Azure Key Vault
│
├── pipelines/
│   ├── build_pipeline.yaml     # CI/CD pipeline: provision infrastructure
│   └── destroy_pipeline.yaml   # Destroy pipeline: teardown infrastructure
│
└── codes/                      # Application source code
    ├── main.py                 # Python app entry point
    ├── index.html              # Frontend HTML
    ├── init.sql                # DB initialisation script
    ├── nginx.cf                # Nginx web server configuration
    └── todo/                   # Todo application module
        ├── main.py
        └── requirements.txt
```

---

## 🔄 CI/CD Pipelines — Azure DevOps

Two dedicated pipelines manage the full infrastructure lifecycle.

### 🟢 Build Pipeline (`build_pipeline.yaml`)

Triggered on push to the main branch. Provisions or updates the full infrastructure.


| Stage | Description |
|-------|-------------|
| **Get Source** | Pulls latest code from GitHub via Azure Repos |
| **TF Install** | Installs the required Terraform version on the agent |
| **TF init** | Initialises backend and downloads providers |
| **TF fmt** | Enforces consistent HCL code formatting |
| **TF validate** | Validates configuration syntax and logic |
| **TF plan** | Generates execution plan; output published for review |
| **TF apply** | Provisions / updates Azure infrastructure |

### 🔴 Destroy Pipeline (`destroy_pipeline.yaml`)

Safely tears down all provisioned infrastructure on demand.

```
┌────────────┐   ┌────────────┐   ┌────────────┐
│ Get Source │──►│ TF Install │──►│ TF destroy │
└────────────┘   └────────────┘   └────────────┘
```

---

## 🔑 Key Features

- **6 Self-Authored Terraform Modules** — `Network`, `Compute`, `application_gateway`, `load_balancer`, `database`, and `keyvault` modules promote reusability and clear separation of concerns
- **Multi-AZ High Availability** — Web and application tiers each span two subnets (`sub01`, `sub02`) across availability zones for fault tolerance
- **YAML-Driven Variable Injection** — Per-component YAML config files (`network.yaml`, `vmss.yaml`, `database.yaml`, etc.) are consumed by the pipeline, cleanly separating configuration from code
- **Remote State Management** — Terraform state stored in Azure Storage Account with locking, safe for collaborative workflows
- **Zero-Trust Networking** — Each tier is isolated in its own subnet; VMs carry no public IPs; all admin access goes through Azure Bastion
- **Secret Management** — All sensitive values (DB credentials, connection strings) are stored in Azure Key Vault — never hardcoded
- **Private DNS Zones** — Internal name resolution for secure, private service-to-service communication
- **Dual Pipelines** — Separate Build and Destroy pipelines give full, safe control over the entire infrastructure lifecycle

---

## 🚀 Getting Started

### Prerequisites

- Azure CLI (`az login`)
- Terraform >= 1.3.0
- Azure DevOps project with a Service Connection to Azure
- GitHub repository connected to Azure DevOps

### Clone the Repository

```bash
git clone https://github.com/pwawslearning/Azure_DevOps.git
cd Azure_DevOps/Project_2
```

### Configure Remote Backend

Update `remote_backend.tf` with your Storage Account details:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "<your-resource-group>"
    storage_account_name = "<your-storage-account>"
    container_name       = "tfstate"
    key                  = "project2.terraform.tfstate"
  }
}
```

### Run via Azure DevOps

- **Build**: Push to `main` → triggers `build_pipeline.yaml` automatically
- **Destroy**: Manually trigger `destroy_pipeline.yaml` from Azure DevOps when teardown is needed

---

## 📚 What I Learned

- Designing a multi-AZ, production-grade three-tier architecture on Azure
- Authoring 6 reusable Terraform modules from scratch with clean input/output interfaces
- Separating environment configuration from infrastructure code using YAML config files
- Building and managing independent Build and Destroy pipelines in Azure DevOps
- Securing infrastructure with Azure Bastion, Key Vault, Private DNS Zones, and a zero-public-IP VM design
- Managing Terraform remote state safely in Azure Storage for team workflows

---

## 👤 Author

**phyowai** — Cloud Engineer
- GitHub: [@pwawslearning](https://github.com/pwawslearning)
- Repo: [pwawslearning/Azure_DevOps](https://github.com/pwawslearning/Azure_DevOps)

---