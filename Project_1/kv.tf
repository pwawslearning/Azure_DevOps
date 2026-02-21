resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
}

resource "azurerm_key_vault" "kv" {
  name                        = "aks-lab-kv0877"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azuread_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
  depends_on                  = [azurerm_resource_group.rg]
  rbac_authorization_enabled = true
}

resource "azurerm_key_vault_secret" "kv_secret" {
  depends_on = [ azurerm_key_vault.kv ]
  name         = azuread_service_principal.sp.client_id
  key_vault_id = azurerm_key_vault.kv.id
  value        = azuread_service_principal_password.psswd.value
}