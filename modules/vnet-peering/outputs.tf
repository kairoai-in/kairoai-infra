output "local_to_remote_id" {
  description = "Local to remote peering ID."
  value       = azurerm_virtual_network_peering.local_to_remote.id
}

output "remote_to_local_id" {
  description = "Remote to local peering ID."
  value       = azurerm_virtual_network_peering.remote_to_local.id
}
