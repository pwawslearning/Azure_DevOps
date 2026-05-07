### Application Gateway creating  ###########

resource "azurerm_public_ip" "apgw_pip" {
  name                = "${var.project}-${var.environment}-apgw_pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku = "Standard"
}

resource "azurerm_web_application_firewall_policy" "waf_policy" {
  name                = "${var.project}-${var.environment}-waf-policy"
  resource_group_name = var.resource_group_name
  location            = var.location

  policy_settings {
    enabled                     = true
    mode                        = "Prevention"
    request_body_check          = true
    max_request_body_size_in_kb = 128
    file_upload_limit_in_mb     = 100
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = var.rule_set_version
    }
  }
}


# since these variables are re-used - a locals block makes this more maintainable
locals {
  apgw_name = "${var.project}-${var.environment}-apgw"
  gateway_ip_configuration_name = "${var.project}-${var.environment}-apgw_ip"
  backend_address_pool_name      = "${var.project}-${var.environment}-beap"
  frontend_port_name             = "${var.project}-${var.environment}-feport"
  frontend_ip_configuration_name = "${var.project}-${var.environment}-feip"
  http_setting_name              = "${var.project}-${var.environment}-be-htst"
  listener_name                  = "${var.project}-${var.environment}-httplstn"
  request_routing_rule_name      = "${var.project}-${var.environment}-rqrt"
  redirect_configuration_name    = "${var.project}-${var.environment}-rdrcfg"
}

resource "azurerm_application_gateway" "apgw" {
  name                = local.apgw_name
  resource_group_name = var.resource_group_name
  location            = var.location

  firewall_policy_id = azurerm_web_application_firewall_policy.waf_policy.id

  sku {
    name     = var.apgw_sku
    tier     = var.apgw_sku
    capacity = var.capacity
  }

  gateway_ip_configuration {
    name      = local.gateway_ip_configuration_name
    subnet_id = var.apgw_subnet_id
  }

  frontend_port {
    name = local.frontend_port_name
    port = var.frontend_port
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.apgw_pip.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = var.cookie_based_affinity
    path                  = var.backend_path
    port                  = var.backend_port
    protocol              = var.backend_protocol
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = var.listener_protocol
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = 10
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }

  probe {
    name                = "health-probe"
    host                = "127.0.0.1"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
    protocol            = var.probe_protocol
    port                = var.backend_port
    path                = "/"
  }
}