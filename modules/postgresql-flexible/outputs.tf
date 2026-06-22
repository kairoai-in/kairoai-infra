output "id" {
  description = "PostgreSQL Flexible Server ID."
  value       = azurerm_postgresql_flexible_server.this.id
}

output "fqdn" {
  description = "PostgreSQL Flexible Server FQDN."
  value       = azurerm_postgresql_flexible_server.this.fqdn
}

output "database_id" {
  description = "Application database ID."
  value       = azurerm_postgresql_flexible_server_database.this.id
}
