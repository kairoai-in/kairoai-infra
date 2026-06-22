output "id" {
  description = "Application Gateway ID."
  value       = azurerm_application_gateway.this.id
}

output "name" {
  description = "Application Gateway name."
  value       = azurerm_application_gateway.this.name
}

output "public_ip_address" {
  description = "Application Gateway public IP address."
  value       = azurerm_public_ip.this.ip_address
}

output "frontend_fqdn" {
  description = "Application Gateway public IP FQDN, if configured by Azure."
  value       = azurerm_public_ip.this.fqdn
}
