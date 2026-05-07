module "Compute" {
  source = "./modules/Compute"

  depends_on = [module.Network, module.application_gateway, module.LoadBalancer]

  for_each = local.vmss_config

  vm_username           = each.value.admin_username
  vmss_name             = format("vmss-%s-%s-%s", var.project, var.environment, each.key)
  resource_group_name   = local.resource_group_name
  location              = var.location
  sku                   = each.value.sku.name
  instances             = each.value.sku.instances
  publisher             = each.value.image.publisher
  os_version            = each.value.image.version
  offer                 = each.value.image.offer
  image_sku             = each.value.image.sku
  vm_nic_name           = "${each.key}-nic"
  vm_ifconfig_subnet_id = module.Network.subnet_ids[each.value.subnet]
  os_disk_size          = each.value.os_disk.size_gb
  storage_account_type  = each.value.os_disk.storage_account_type

  autoscale_min                     = each.value.autoscale.min
  autoscale_max                     = each.value.autoscale.max
  autoscale_cpu_scale_out_threshold = each.value.autoscale.cpu_scale_out
  autoscale_cpu_scale_in_threshold  = each.value.autoscale.cpu_scale_in

  # Conditionally pass backend pool ID based on tier
  appgw_backend_pool_id = each.value.backend_pool == "appgw" ? module.application_gateway.backend_address_pool_id : null
  lb_backend_pool_id    = each.value.backend_pool == "lb" ? module.LoadBalancer.backend_address_pool_id : null

}