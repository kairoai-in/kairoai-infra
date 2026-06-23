output "id" {
  description = "Azure AI Services account ID."
  value       = azurerm_cognitive_account.this.id
}

output "endpoint" {
  description = "Azure AI Services endpoint."
  value       = azurerm_cognitive_account.this.endpoint
}

output "principal_id" {
  description = "Azure AI Services managed identity principal ID."
  value       = azurerm_cognitive_account.this.identity[0].principal_id
}

output "primary_access_key" {
  description = "Primary Azure AI Services access key."
  value       = azurerm_cognitive_account.this.primary_access_key
  sensitive   = true
}

output "deployment_ids" {
  description = "Azure AI deployment IDs keyed by deployment name."
  value       = { for name, deployment in azurerm_cognitive_deployment.this : name => deployment.id }
}
