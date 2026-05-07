# Get current client details for access policy
data "azurerm_client_config" "current" {}

# Create Key Vault
resource "azurerm_key_vault" "kv" {
  name                        = "${var.project}-${var.environment}-kv"
  resource_group_name         = var.resource_group_name
  location                    = var.location
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = true
  soft_delete_retention_days  = 7

  # Allow Terraform service principal to manage secrets
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "Set",
      "Delete",
      "List",
      "Purge",
      "Recover"
    ]
  }
}

# Generate random password
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%"    # Azure PostgreSQL allowed special chars
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
}

# Store password in Key Vault
resource "azurerm_key_vault_secret" "db_password" {
  name         = "${var.project}-${var.environment}-db-password"
  value        = random_password.db_password.result
  key_vault_id = azurerm_key_vault.kv.id

  lifecycle {
    ignore_changes = [value]   # prevent Terraform from rotating password on every apply
  }
}

# Allow each VMSS managed identity to read secrets from Key Vault
resource "azurerm_key_vault_access_policy" "vmss_policy" {
  for_each = var.vmss_identity_ids

  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = each.value

  secret_permissions = [
    "Get",
    "List"
  ]
}