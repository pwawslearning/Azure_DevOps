module "LoadBalancer" {
  source = "./modules/load_balancer"

  depends_on = [module.Network, module.application_gateway]

  resource_group_name = local.resource_group_name
  location            = var.location
  environment         = var.environment
  project             = var.project

  lb_subnet            = module.Network.subnet_ids["app_sub01"]
  backend_port         = local.lb_config.backend_port
  backend_protocol     = local.lb_config.backend_protocol
  probe_request_path   = local.lb_config.probe_request_path
  probe_interval       = local.lb_config.probe_interval
  application_port     = local.lb_config.application_port
  application_protocol = local.lb_config.application_protocol



}