output "names" {
  description = "Planned prod DR resource names."
  value       = local.names
}

output "vnet_cidr" {
  description = "Planned prod DR VNet CIDR."
  value       = var.vnet_cidr
}

output "subnets" {
  description = "Planned prod DR subnet CIDRs."
  value       = { for name, subnet in local.subnets : name => subnet.address_prefixes[0] }
}

output "resource_group_name" {
  description = "Prod DR resource group name."
  value       = module.resource_group.name
}

output "vnet_id" {
  description = "Prod DR spoke VNet ID."
  value       = module.networking.vnet_id
}

output "subnet_ids" {
  description = "Prod DR spoke subnet IDs."
  value       = module.networking.subnet_ids
}

output "key_vault_uri" {
  description = "Prod DR Key Vault URI."
  value       = module.key_vault.uri
}

output "service_bus_namespace_id" {
  description = "Prod DR Service Bus namespace ID when enabled."
  value       = var.enable_service_bus ? module.service_bus[0].namespace_id : null
}

output "postgresql_fqdn" {
  description = "Prod DR PostgreSQL Flexible Server FQDN when enabled."
  value       = var.enable_postgresql ? module.postgresql[0].fqdn : null
}

output "log_analytics_workspace_id" {
  description = "Prod DR Log Analytics workspace ID."
  value       = module.monitor.log_analytics_workspace_id
}

output "application_insights_connection_string" {
  description = "Prod DR Application Insights connection string."
  value       = module.monitor.application_insights_connection_string
  sensitive   = true
}

output "aks_cluster_id" {
  description = "Prod DR AKS cluster ID when enabled."
  value       = var.enable_aks ? module.aks[0].id : null
}

output "aks_cluster_name" {
  description = "Prod DR AKS cluster name when enabled."
  value       = var.enable_aks ? module.aks[0].name : null
}

output "aks_oidc_issuer_url" {
  description = "Prod DR AKS OIDC issuer URL when enabled."
  value       = var.enable_aks ? module.aks[0].oidc_issuer_url : null
}

output "app_gateway_public_ip_address" {
  description = "Prod DR Application Gateway public IP address when enabled."
  value       = var.enable_app_gateway_waf ? module.app_gateway_waf[0].public_ip_address : null
}

output "ai_foundry_endpoint" {
  description = "Prod DR Azure AI Services endpoint when enabled."
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
