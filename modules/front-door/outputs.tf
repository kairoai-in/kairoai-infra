
output "endpoint_id" {
  description = "Front Door endpoint ID."
  value       = azurerm_cdn_frontdoor_endpoint.this.id
}

output "endpoint_host_name" {
  description = "Front Door endpoint hostname."
  value       = azurerm_cdn_frontdoor_endpoint.this.host_name
}

output "profile_id" {
  description = "Front Door profile ID."
  value       = azurerm_cdn_frontdoor_profile.this.id
}

output "custom_domain_validation_tokens" {
  description = "Front Door custom domain validation tokens keyed by route name."
  value       = { for name, domain in azurerm_cdn_frontdoor_custom_domain.this : name => domain.validation_token }
}
