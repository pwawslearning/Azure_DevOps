-- DB Tier — Azure Database for PostgreSQL
-- Run this ONCE via psql or Azure Cloud Shell after provisioning the server
-- Connection string example:
--   psql "host=your-server.postgres.database.azure.com port=5432 dbname=tododb user=todoadmin sslmode=require"

-- Create the database (run as admin user if tododb doesn't exist yet)
-- CREATE DATABASE tododb;

-- Todos table
CREATE TABLE IF NOT EXISTS todos (
    id         SERIAL PRIMARY KEY,
    title      VARCHAR(200) NOT NULL,
    done       BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- Index for fast ordering
CREATE INDEX IF NOT EXISTS idx_todos_created ON todos(created_at DESC);

-- Sample data to verify the setup works
INSERT INTO todos (title, done) VALUES
  ('Deploy Web VMSS',  true),
  ('Deploy App VMSS',  true),
  ('Connect to Azure PostgreSQL', false),
  ('Test the To-Do app end to end', false);

-- Verify
SELECT * FROM todos ORDER BY id;