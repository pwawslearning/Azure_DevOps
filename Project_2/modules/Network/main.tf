
resource "azurerm_virtual_network" "vnet" {
  name = var.vnet_name
  resource_group_name = var.resource_group_name
  location = var.location
  address_space = [var.address_space]
}

resource "azurerm_subnet" "subnets" {
  for_each = var.subnets_name

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value.address_prefix]
  service_endpoints = [var.service_endpoints]


  # Only add delegation block for DB subnets
  dynamic "delegation" {
    for_each = each.value.delegate_to_postgres ? [1] : []

    content {
      name = "fs"
      service_delegation {
        name = "Microsoft.DBforPostgreSQL/flexibleServers"
        actions = [
          "Microsoft.Network/virtualNetworks/subnets/join/action",
        ]
      }
    }
  }
}

resource "azurerm_network_security_group" "nsg" {
  for_each = var.nsg_names

  name                = "${each.key}-nsg"
  resource_group_name = var.resource_group_name
  location            = var.location

  dynamic "security_rule" {
    for_each = each.value.nsg_rules

    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      # Use plural if multiple prefixes provided, else singular
      source_address_prefix        = length(coalesce(security_rule.value.source_address_prefixes, [])) > 0 ? null : security_rule.value.source_address_prefix
      source_address_prefixes      = length(coalesce(security_rule.value.source_address_prefixes, [])) > 0 ? security_rule.value.source_address_prefixes : null
      destination_address_prefix   = length(coalesce(security_rule.value.destination_address_prefixes, [])) > 0 ? null : security_rule.value.destination_address_prefix
      destination_address_prefixes = length(coalesce(security_rule.value.destination_address_prefixes, [])) > 0 ? security_rule.value.destination_address_prefixes : null

    }
  }
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg_assoc" {

  for_each = var.nsg_names

  subnet_id                 = azurerm_subnet.subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id

}

## NAT Gateway Creating ##

resource "azurerm_public_ip" "natgw_pip" {
  name = "${var.project}-${var.environment}-natgwpip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
}

resource "azurerm_nat_gateway" "natgw" {
  name                = "${var.project}-${var.environment}-natgw"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "natgwasso" {

  nat_gateway_id       = azurerm_nat_gateway.natgw.id
  public_ip_address_id = azurerm_public_ip.natgw_pip.id
}

# Associate NAT Gateway with app tier subnets
resource "azurerm_subnet_nat_gateway_association" "private" {
  for_each = var.nat_gateway_subnets                    

  subnet_id      = azurerm_subnet.subnets[each.key].id 
  nat_gateway_id = azurerm_nat_gateway.natgw.id
}

## Bastion host creating ##

resource "azurerm_public_ip" "bastion_pip" {
  name = "${var.project}-${var.environment}-bastion_pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
}

resource "azurerm_bastion_host" "bastion" {
  name                = "${var.project}-${var.environment}-bastion"
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                 = "bastion-ipconfig"
    subnet_id            = azurerm_subnet.subnets["AzureBastionSubnet"].id  
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }
}

# Create Private DNS zone
resource "azurerm_private_dns_zone" "private_dns" {
  name                = "${var.project}.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                  = "${var.project}VnetZone.com"
  private_dns_zone_name = azurerm_private_dns_zone.private_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = var.resource_group_name
  depends_on            = [azurerm_subnet.subnets]
}