output "id" {
  description = "Private endpoint resource ID."
  value       = azurerm_private_endpoint.this.id
}

output "private_service_connection" {
  description = "Private service connection details."
  value       = azurerm_private_endpoint.this.private_service_connection
}
