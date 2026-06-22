output "names" {
  description = "Planned test resource names."
  value       = local.names
}

output "vnet_cidr" {
  description = "Planned test VNet CIDR."
  value       = var.vnet_cidr
}

output "subnets" {
  description = "Planned test subnet CIDRs."
  value       = local.subnets
}

output "resource_group_name" {
  description = "Test resource group name."
  value       = azurerm_resource_group.test.name
}

output "vnet_id" {
  description = "Test spoke VNet ID."
  value       = azurerm_virtual_network.test.id
}

output "subnet_ids" {
  description = "Test spoke subnet IDs."
  value       = { for name, subnet in azurerm_subnet.test : name => subnet.id }
}

output "key_vault_uri" {
  description = "Test Key Vault URI."
  value       = azurerm_key_vault.test.vault_uri
}

output "service_bus_namespace_id" {
  description = "Test Service Bus namespace ID."
  value       = azurerm_servicebus_namespace.test.id
}

output "postgresql_fqdn" {
  description = "Test PostgreSQL Flexible Server FQDN."
  value       = azurerm_postgresql_flexible_server.test.fqdn
}

output "log_analytics_workspace_id" {
  description = "Test Log Analytics workspace ID."
  value       = azurerm_log_analytics_workspace.test.id
}

output "application_insights_connection_string" {
  description = "Test Application Insights connection string."
  value       = azurerm_application_insights.test.connection_string
  sensitive   = true
}
