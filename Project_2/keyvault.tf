module "KeyVault" {
  source = "./modules/keyvault"

  project             = var.project
  environment         = var.environment
  resource_group_name = local.resource_group_name
  location            = var.location

  vmss_identity_ids = {
    for k, v in module.Compute : k => v.vmss_identity_id
  }
}