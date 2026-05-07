"""
App Tier — FastAPI To-Do API
Single file, minimal dependencies.
Connects to Azure Database for PostgreSQL (DB Tier).

Endpoints:
  GET    /api/todos        — list all todos
  POST   /api/todos        — create a todo
  PUT    /api/todos/{id}   — update (toggle done / rename)
  DELETE /api/todos/{id}   — delete a todo
  GET    /health           — health check (for Azure LB probe)
"""

import os
import logging
from contextlib import asynccontextmanager
from typing import Optional

import asyncpg
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

# ── Logging ───────────────────────────────────────────────────────────────────
logging.basicConfig(level=logging.INFO,
                    format="%(asctime)s | %(levelname)s | %(message)s")
log = logging.getLogger(__name__)

# ── Config from environment variables ────────────────────────────────────────
DB_HOST     = os.getenv("DB_HOST",     "your-server.postgres.database.azure.com")
DB_PORT     = int(os.getenv("DB_PORT", "5432"))
DB_NAME     = os.getenv("DB_NAME",     "tododb")
DB_USER     = os.getenv("DB_USER",     "todoadmin")
DB_PASSWORD = os.getenv("DB_PASSWORD", "changeme")
DB_SSL      = os.getenv("DB_SSL",      "require")   # Azure PostgreSQL requires SSL

# ── Connection pool (shared across all requests) ──────────────────────────────
pool: asyncpg.Pool = None


@asynccontextmanager
async def lifespan(app: FastAPI):
    global pool
    log.info("Connecting to Azure PostgreSQL...")
    pool = await asyncpg.create_pool(
        host=DB_HOST, port=DB_PORT,
        database=DB_NAME, user=DB_USER, password=DB_PASSWORD,
        ssl=DB_SSL,
        min_size=2, max_size=10,
        command_timeout=30,
    )
    # Create table if it doesn't exist yet
    async with pool.acquire() as conn:
        await conn.execute("""
            CREATE TABLE IF NOT EXISTS todos (
                id         SERIAL PRIMARY KEY,
                title      VARCHAR(200) NOT NULL,
                done       BOOLEAN NOT NULL DEFAULT FALSE,
                created_at TIMESTAMPTZ  NOT NULL DEFAULT NOW()
            )
        """)
    log.info("Database ready.")
    yield
    await pool.close()
    log.info("Shutdown complete.")


# ── App ───────────────────────────────────────────────────────────────────────
app = FastAPI(title="To-Do API", version="1.0.0", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],   # tighten to Web VMSS IP / domain in production
    allow_methods=["*"],
    allow_headers=["*"],
)


# ── Schemas ───────────────────────────────────────────────────────────────────
class TodoCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=200)

class TodoUpdate(BaseModel):
    title: Optional[str] = Field(None, min_length=1, max_length=200)
    done:  Optional[bool] = None

class TodoOut(BaseModel):
    id:    int
    title: str
    done:  bool


# ── Routes ────────────────────────────────────────────────────────────────────

@app.get("/api/todos", response_model=list[TodoOut])
async def list_todos():
    async with pool.acquire() as conn:
        rows = await conn.fetch(
            "SELECT id, title, done FROM todos ORDER BY id"
        )
    return [dict(r) for r in rows]


@app.post("/api/todos", response_model=TodoOut, status_code=201)
async def create_todo(payload: TodoCreate):
    async with pool.acquire() as conn:
        row = await conn.fetchrow(
            "INSERT INTO todos (title) VALUES ($1) RETURNING id, title, done",
            payload.title,
        )
    log.info(f"Created todo id={row['id']}")
    return dict(row)


@app.put("/api/todos/{todo_id}", response_model=TodoOut)
async def update_todo(todo_id: int, payload: TodoUpdate):
    async with pool.acquire() as conn:
        # Fetch existing
        existing = await conn.fetchrow(
            "SELECT id, title, done FROM todos WHERE id = $1", todo_id
        )
        if not existing:
            raise HTTPException(status_code=404, detail="Todo not found")

        new_title = payload.title if payload.title is not None else existing["title"]
        new_done  = payload.done  if payload.done  is not None else existing["done"]

        row = await conn.fetchrow(
            """UPDATE todos SET title=$1, done=$2
               WHERE id=$3 RETURNING id, title, done""",
            new_title, new_done, todo_id,
        )
    log.info(f"Updated todo id={todo_id}")
    return dict(row)


@app.delete("/api/todos/{todo_id}", status_code=204)
async def delete_todo(todo_id: int):
    async with pool.acquire() as conn:
        result = await conn.execute(
            "DELETE FROM todos WHERE id = $1", todo_id
        )
    if result == "DELETE 0":
        raise HTTPException(status_code=404, detail="Todo not found")
    log.info(f"Deleted todo id={todo_id}")


# ── Health check (Azure Load Balancer probe) ──────────────────────────────────
@app.get("/health")
async def health():
    try:
        async with pool.acquire() as conn:
            await conn.fetchval("SELECT 1")
        db_status = "ok"
    except Exception as e:
        log.error(f"DB health check failed: {e}")
        db_status = "error"
    return {
        "status": "healthy" if db_status == "ok" else "degraded",
        "tier": "app",
        "db": db_status,
    }