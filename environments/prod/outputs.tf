output "names" {
  description = "Planned prod resource names."
  value       = local.names
}

output "vnet_cidr" {
  description = "Planned prod VNet CIDR."
  value       = var.vnet_cidr
}

output "subnets" {
  description = "Planned prod subnet CIDRs."
  value       = { for name, subnet in local.subnets : name => subnet.address_prefixes[0] }
}

output "resource_group_name" {
  description = "Prod resource group name."
  value       = module.resource_group.name
}

output "vnet_id" {
  description = "Prod spoke VNet ID."
  value       = module.networking.vnet_id
}

output "subnet_ids" {
  description = "Prod spoke subnet IDs."
  value       = module.networking.subnet_ids
}

output "key_vault_uri" {
  description = "Prod Key Vault URI."
  value       = module.key_vault.uri
}

output "service_bus_namespace_id" {
  description = "Prod Service Bus namespace ID."
  value       = module.service_bus.namespace_id
}

output "postgresql_fqdn" {
  description = "Prod PostgreSQL Flexible Server FQDN."
  value       = module.postgresql.fqdn
}

output "log_analytics_workspace_id" {
  description = "Prod Log Analytics workspace ID."
  value       = module.monitor.log_analytics_workspace_id
}

output "application_insights_connection_string" {
  description = "Prod Application Insights connection string."
  value       = module.monitor.application_insights_connection_string
  sensitive   = true
}

output "aks_cluster_id" {
  description = "Prod AKS cluster ID when enabled."
  value       = var.enable_aks ? module.aks[0].id : null
}

output "aks_cluster_name" {
  description = "Prod AKS cluster name when enabled."
  value       = var.enable_aks ? module.aks[0].name : null
}

output "aks_oidc_issuer_url" {
  description = "Prod AKS OIDC issuer URL when enabled."
  value       = var.enable_aks ? module.aks[0].oidc_issuer_url : null
}

output "app_gateway_public_ip_address" {
  description = "Prod Application Gateway public IP address when enabled."
  value       = var.enable_app_gateway_waf ? module.app_gateway_waf[0].public_ip_address : null
}

output "agic_identity_object_id" {
  description = "Prod managed AGIC add-on identity object ID."
  value       = var.enable_aks && var.enable_app_gateway_waf ? module.aks[0].agic_identity_object_id : null
}

output "ai_foundry_endpoint" {
  description = "Prod Azure AI Services endpoint when enabled."
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
