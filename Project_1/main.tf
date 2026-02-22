module "service_principal" {
  source = "./modules/service_principal"
}


data "azurerm_subscription" "sub" {
  
}

resource "azurerm_role_assignment" "sp_role" {
  scope = data.azurerm_subscription.sub.id
  role_definition_name = "Contributor"
  principal_id = module.service_principal.service_principal_object_id
}

module "key_vault" {
  source = "./modules/key_vault"
  location = var.location
  sku_name = var.sku_name
}

resource "azurerm_key_vault_secret" "kv_secret" {
  depends_on = [ module.key_vault ]
  name         = module.service_principal.client_id
  key_vault_id = module.key_vault.key_vault_id
  value        = module.service_principal.client_secret
}

module "aks" {
  source = "./modules/aks"
  location = var.location
  client_id = module.service_principal.client_id
  client_secret = module.service_principal.client_secret
}