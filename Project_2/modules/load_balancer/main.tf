resource "azurerm_lb" "lb" {
  name                = "${var.project}-${var.environment}-lb"
  location            = var.location
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                 = "lb-frontipconfig"
    subnet_id = var.lb_subnet
    private_ip_address_allocation = "Dynamic"

  }
}

resource "azurerm_lb_backend_address_pool" "lb_backend_pool" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "lb_backend_pool"
}

resource "azurerm_lb_probe" "lb_probe" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "lb-probe"
  port            = var.backend_port
  protocol = var.backend_protocol
  request_path = var.probe_request_path
  interval_in_seconds = var.probe_interval

}

resource "azurerm_lb_rule" "lb_rule" {
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "Lb_Rule"
  protocol                       = var.application_protocol
  frontend_port                  = var.application_port
  backend_port                   = var.application_port
  frontend_ip_configuration_name = "lb-frontipconfig"
  backend_address_pool_ids = [ azurerm_lb_backend_address_pool.lb_backend_pool.id ]
  probe_id = azurerm_lb_probe.lb_probe.id
}