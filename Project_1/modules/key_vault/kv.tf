resource "azurerm_resource_group" "rg" {
  name     = "${var.proj}-${var.env}-rg"
  location = var.location
}

data "azuread_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                        = "${var.proj}-${var.env}-kv115"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azuread_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = var.sku_name
  depends_on                  = [azurerm_resource_group.rg]
  rbac_authorization_enabled = true
}

output "key_vault_id" {
  value = azurerm_key_vault.kv.id
}