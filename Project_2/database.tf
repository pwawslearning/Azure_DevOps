module "Database" {
  source = "./modules/database"

  resource_group_name = local.resource_group_name
  location            = var.location
  project             = var.project

  db_subnets       = module.Network.subnet_ids["db_sub01"]
  private_dns_zone = module.Network.private_dns_zone_id

  dbadmin_login    = local.db_config.admin_login
  dbadmin_password = module.KeyVault.db_password
  dbstorage_mb     = local.db_config.storage_mb
  dbstorage_tier   = local.db_config.storage_tier
  DBsku_name       = local.db_config.sku_name
}