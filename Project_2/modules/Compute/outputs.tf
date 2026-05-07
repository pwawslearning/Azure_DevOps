output "vmss_id" {
  description = "VMSS resource ID"
  value       = azurerm_linux_virtual_machine_scale_set.vmss.id
}

output "vmss_identity_id" {
  description = "Principal ID of the VMSS user assigned identity"
  value       = azurerm_user_assigned_identity.this.principal_id 
}