resource "azurerm_postgresql_flexible_server" "psglDB" {
  name                          = "${var.project}-psqlflexibleserver"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = "12"
  delegated_subnet_id           = var.db_subnets
  private_dns_zone_id           = var.private_dns_zone
  public_network_access_enabled = false
  administrator_login           = var.dbadmin_login
  administrator_password        = var.dbadmin_password
  zone                          = "1"

  storage_mb   = var.dbstorage_mb #32768
  storage_tier = var.dbstorage_tier #"P4"

  sku_name   = var.DBsku_name #"B_Standard_B1ms"

}