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
  value       = { for name, subnet in local.subnets : name => subnet.address_prefixes[0] }
}

output "resource_group_name" {
  description = "Test resource group name."
  value       = module.resource_group.name
}

output "vnet_id" {
  description = "Test spoke VNet ID."
  value       = module.networking.vnet_id
}

output "subnet_ids" {
  description = "Test spoke subnet IDs."
  value       = module.networking.subnet_ids
}

output "key_vault_uri" {
  description = "Test Key Vault URI."
  value       = module.key_vault.uri
}

output "service_bus_namespace_id" {
  description = "Test Service Bus namespace ID."
  value       = module.service_bus.namespace_id
}

output "postgresql_fqdn" {
  description = "Test PostgreSQL Flexible Server FQDN."
  value       = module.postgresql.fqdn
}

output "log_analytics_workspace_id" {
  description = "Test Log Analytics workspace ID."
  value       = module.monitor.log_analytics_workspace_id
}

output "application_insights_connection_string" {
  description = "Test Application Insights connection string."
  value       = module.monitor.application_insights_connection_string
  sensitive   = true
}

output "aks_cluster_id" {
  description = "Test AKS cluster ID."
  value       = module.aks.id
}

output "aks_cluster_name" {
  description = "Test AKS cluster name."
  value       = module.aks.name
}

output "aks_oidc_issuer_url" {
  description = "Test AKS OIDC issuer URL for workload identity."
  value       = module.aks.oidc_issuer_url
}

output "azure_monitor_workspace_id" {
  description = "Azure Monitor workspace ID for managed Prometheus metrics."
  value       = azurerm_monitor_workspace.test.id
}

output "managed_grafana_endpoint" {
  description = "Azure Managed Grafana endpoint."
  value       = azurerm_dashboard_grafana.test.endpoint
}

output "managed_grafana_id" {
  description = "Azure Managed Grafana resource ID."
  value       = azurerm_dashboard_grafana.test.id
}

output "app_gateway_public_ip_address" {
  description = "Application Gateway public IP address when enabled."
  value       = var.enable_app_gateway_waf ? module.app_gateway_waf[0].public_ip_address : null
}

output "ai_foundry_endpoint" {
  description = "Azure AI Services endpoint when enabled."
  value       = var.enable_ai_foundry ? module.ai_foundry[0].endpoint : null
}

output "managed_identity_client_ids" {
  description = "Managed identity client IDs keyed by identity name."
  value       = { for name, identity in module.managed_identity : name => identity.client_id }
}

output "policy_assignment_ids" {
  description = "Azure Policy assignment IDs keyed by assignment name."
  value       = module.policy.assignment_ids
}
