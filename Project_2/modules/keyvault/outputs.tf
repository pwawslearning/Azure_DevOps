output "key_vault_id" {
  description = "Key Vault resource ID"
  value       = azurerm_key_vault.kv.id
}

output "db_password_secret_id" {
  description = "Key Vault secret ID for DB password"
  value       = azurerm_key_vault_secret.db_password.id
}

output "db_password" {
  description = "Database admin password"
  value       = azurerm_key_vault_secret.db_password.value
  sensitive   = true    # hides value from logs and plan output
}