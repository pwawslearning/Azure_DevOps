variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "address_space" {
  type = string
}

variable "subnets_name" {
  description = "Map of subnet names and address prefixes"
  type = map(object({
    address_prefix = string
    nat_gateway    = optional(bool, false)
    delegate_to_postgres = optional(bool, false)
  }))
}

variable "nat_gateway_subnets" {
  description = "Map of subnets to associate with NAT Gateway"
  type = map(object({
    address_prefix = string
    nat_gateway    = optional(bool, false)
    delegate_to_postgres = optional(bool, false)
  }))
  default = {}
}

variable "service_endpoints" {
  type = string
  default = "Microsoft.storage"
}

variable "nsg_names" {
  description = "NSG rules configuration"

  type = map(object({
    nsg_rules = list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix       = optional(string)
      source_address_prefixes     = optional(list(string))
      destination_address_prefix  = optional(string)
      destination_address_prefixes = optional(list(string))
    }))
  }))
  # default = {
  #   pub_sub01 = {

  #   nsg_rules = [
  #     {
  #       name                       = "allow_ssh"
  #       priority                   = 100
  #       direction                  = "Inbound"
  #       access                     = "Allow"
  #       protocol                   = "Tcp"
  #       source_port_range          = "*"
  #       destination_port_range     = "22"
  #       source_address_prefix      = "*"
  #       destination_address_prefix = "*"
  #     }
  #   ]
  # }
# }
}

variable "environment" {
  type = string
}

variable "project" {
  type = string
}