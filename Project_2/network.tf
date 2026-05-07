module "Network" {
  source = "./modules/Network"

  depends_on = [ azurerm_resource_group.rg ]

  resource_group_name = local.resource_group_name
  location            = var.location
  environment         = var.environment
  project             = var.project

  vnet_name     = local.vnet_name
  address_space = local.vnet_config.address_space
  subnets_name  = local.vnet_config.subnets
  nsg_names     = local.nsg_config


}

