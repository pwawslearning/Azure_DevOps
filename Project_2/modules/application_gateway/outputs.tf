output "backend_address_pool_id" {
  description = "Application Gateway backend address pool ID"
  value = one([
    for pool in azurerm_application_gateway.apgw.backend_address_pool :
    pool.id if pool.name == local.backend_address_pool_name
  ])
}