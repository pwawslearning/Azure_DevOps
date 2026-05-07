output "backend_address_pool_id" {
  description = "Load Balancer backend address pool ID"
  value       = azurerm_lb_backend_address_pool.lb_backend_pool.id
}