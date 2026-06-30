output "id" {
  description = "Argo CD extension resource ID."
  value       = azurerm_kubernetes_cluster_extension.this.id
}

output "name" {
  description = "Argo CD extension name."
  value       = azurerm_kubernetes_cluster_extension.this.name
}

output "namespace" {
  description = "Argo CD namespace."
  value       = var.namespace
}
