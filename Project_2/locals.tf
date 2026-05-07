locals {

  network_config     = yamldecode(file("${path.root}/config/network.yaml"))
  compute_config     = yamldecode(file("${path.root}/config/vmss.yaml"))
  apgw_config        = yamldecode(file("${path.root}/config/frontend.yaml"))
  lb_config          = yamldecode(file("${path.root}/config/backend.yaml"))["load_balancer"]
  postgres_DB_config = yamldecode(file("${path.root}/config/database.yaml"))



  vnet_config     = local.network_config.vnet
  nsg_config      = local.network_config.nsg
  vmss_config     = local.compute_config.vmss
  frontend_config = local.apgw_config.application_gateway
  db_config       = local.postgres_DB_config.posgres_sql_db


  resource_group_name = "${var.project}-${var.environment}-rg"
  vnet_name           = format("vnet-%s-%s", var.project, var.environment)

  nat_gateway_subnets = {
    for name, config in local.vnet_config.subnets :
    name => config
    if config.nat_gateway == true
  }
}