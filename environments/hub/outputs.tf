output "names" {
  description = "Planned hub resource names."
  value       = local.names
}

output "vnet_cidr" {
  description = "Planned hub VNet CIDR."
  value       = var.vnet_cidr
}

output "subnets" {
  description = "Planned hub subnet CIDRs."
  value       = local.subnets
}

output "resource_group_name" {
  description = "Hub resource group name."
  value       = azurerm_resource_group.hub.name
}

output "vnet_id" {
  description = "Hub VNet ID."
  value       = azurerm_virtual_network.hub.id
}

output "subnet_ids" {
  description = "Hub subnet IDs."
  value       = { for name, subnet in azurerm_subnet.hub : name => subnet.id }
}

output "public_dns_name_servers" {
  description = "Azure DNS name servers for kairoai.in. Configure these in GoDaddy after approval."
  value       = azurerm_dns_zone.public.name_servers
}

output "front_door_endpoint_host_name" {
  description = "Shared hub Front Door endpoint hostname."
  value       = module.front_door.endpoint_host_name
}

output "front_door_custom_domain_validation_tokens" {
  description = "Shared Front Door managed certificate validation tokens keyed by route name."
  value       = module.front_door.custom_domain_validation_tokens
}

output "private_dns_zone_ids" {
  description = "Private DNS zone IDs."
  value       = { for name, zone in azurerm_private_dns_zone.hub : name => zone.id }
}

output "acr_login_server" {
  description = "Hub ACR login server."
  value       = azurerm_container_registry.hub.login_server
}

output "log_analytics_workspace_id" {
  description = "Hub Log Analytics workspace ID."
  value       = azurerm_log_analytics_workspace.hub.id
}

output "key_vault_uri" {
  description = "Hub Key Vault URI."
  value       = azurerm_key_vault.hub.vault_uri
}

output "cost_deferred_resources" {
  description = "High-cost hub resources intentionally deferred from the first foundation apply."
  value       = local.cost_deferred_resources
}
