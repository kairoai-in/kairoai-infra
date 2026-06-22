output "id" {
  description = "Key Vault ID."
  value       = azurerm_key_vault.this.id
}

output "uri" {
  description = "Key Vault URI."
  value       = azurerm_key_vault.this.vault_uri
}

output "admin_role_assignment_id" {
  description = "Bootstrap admin role assignment ID."
  value       = azurerm_role_assignment.current_user_admin.id
}
