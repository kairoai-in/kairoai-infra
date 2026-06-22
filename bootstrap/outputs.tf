output "resource_group_name" {
  value = azurerm_resource_group.state.name
}

output "storage_account_name" {
  value = azurerm_storage_account.state.name
}

output "container_names" {
  value = sort(keys(azurerm_storage_container.state))
}

output "backend_config" {
  value = {
    resource_group_name  = azurerm_resource_group.state.name
    storage_account_name = azurerm_storage_account.state.name
    container_names      = sort(keys(azurerm_storage_container.state))
  }
}

output "state_blob_data_contributor_principal_ids" {
  value = sort(keys(azurerm_role_assignment.state_blob_data_contributor))
}
