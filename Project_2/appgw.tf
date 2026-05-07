module "application_gateway" {
  source = "./modules/application_gateway"

  depends_on = [module.Network]

  resource_group_name = local.resource_group_name
  project             = var.project
  environment         = var.environment
  location            = var.location

  apgw_sku              = local.frontend_config.sku.tier
  capacity              = local.frontend_config.sku.capacity
  frontend_port         = local.frontend_config.frontend_port.port
  cookie_based_affinity = local.frontend_config.backend_http_settings.cookie_based_affinity
  backend_path          = local.frontend_config.backend_http_settings.path
  backend_protocol      = local.frontend_config.backend_http_settings.protocol
  listener_protocol     = local.frontend_config.listener.protocol
  probe_protocol        = local.frontend_config.probe.protocol
  backend_port          = local.frontend_config.probe.port
  rule_set_version      = tostring(local.frontend_config.waf_config.version)
  apgw_subnet_id        = module.Network.subnet_ids["apgw_sub01"]
}