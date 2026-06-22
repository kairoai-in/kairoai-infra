moved {
  from = azurerm_resource_group.test
  to   = module.resource_group.azurerm_resource_group.this
}

moved {
  from = azurerm_virtual_network.test
  to   = module.networking.azurerm_virtual_network.this
}

moved {
  from = azurerm_subnet.test
  to   = module.networking.azurerm_subnet.this
}

moved {
  from = azurerm_virtual_network_peering.test_to_hub
  to   = module.vnet_peering.azurerm_virtual_network_peering.local_to_remote
}

moved {
  from = azurerm_virtual_network_peering.hub_to_test
  to   = module.vnet_peering.azurerm_virtual_network_peering.remote_to_local
}

moved {
  from = azurerm_private_dns_zone_virtual_network_link.test
  to   = module.private_dns_links.azurerm_private_dns_zone_virtual_network_link.this
}

moved {
  from = azurerm_log_analytics_workspace.test
  to   = module.monitor.azurerm_log_analytics_workspace.this
}

moved {
  from = azurerm_application_insights.test
  to   = module.monitor.azurerm_application_insights.this
}

moved {
  from = azurerm_key_vault.test
  to   = module.key_vault.azurerm_key_vault.this
}

moved {
  from = azurerm_role_assignment.test_key_vault_admin
  to   = module.key_vault.azurerm_role_assignment.current_user_admin
}

moved {
  from = azurerm_servicebus_namespace.test
  to   = module.service_bus.azurerm_servicebus_namespace.this
}

moved {
  from = azurerm_servicebus_queue.review_jobs
  to   = module.service_bus.azurerm_servicebus_queue.this["review-jobs"]
}

moved {
  from = azurerm_servicebus_queue.analysis_results
  to   = module.service_bus.azurerm_servicebus_queue.this["analysis-results"]
}

moved {
  from = random_password.postgres_admin
  to   = module.postgresql.random_password.admin
}

moved {
  from = azurerm_postgresql_flexible_server.test
  to   = module.postgresql.azurerm_postgresql_flexible_server.this
}

moved {
  from = azurerm_postgresql_flexible_server_database.app
  to   = module.postgresql.azurerm_postgresql_flexible_server_database.this
}

moved {
  from = azurerm_key_vault_secret.postgres_admin_password
  to   = module.postgresql.azurerm_key_vault_secret.admin_password
}
