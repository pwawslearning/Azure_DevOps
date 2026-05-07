output "subnet_ids" {
  value = { for k, v in azurerm_subnet.subnets : k => v.id }
}

output "private_dns_zone_id" {
  value = azurerm_private_dns_zone.private_dns.id
}