resource "azurerm_monitor_workspace" "prod" {
  name                = local.names.monitor_workspace
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tags                = local.tags
}

resource "azurerm_dashboard_grafana" "prod" {
  name                              = local.names.managed_grafana
  resource_group_name               = module.resource_group.name
  location                          = module.resource_group.location
  api_key_enabled                   = false
  deterministic_outbound_ip_enabled = true
  grafana_major_version             = "12"
  public_network_access_enabled     = var.grafana_public_network_access_enabled
  sku                               = "Standard"

  identity {
    type = "SystemAssigned"
  }

  azure_monitor_workspace_integrations {
    resource_id = azurerm_monitor_workspace.prod.id
  }

  tags = local.tags
}

data "azurerm_monitor_data_collection_rule" "aks_managed_prometheus" {
  count = var.enable_aks ? 1 : 0

  name                = "MSProm-${module.resource_group.location}-${local.names.aks}"
  resource_group_name = module.resource_group.name

  depends_on = [module.aks]
}

resource "azurerm_monitor_data_collection_rule_association" "aks_managed_prometheus" {
  count = var.enable_aks ? 1 : 0

  name                    = "ContainerInsightsMetricsExtension"
  target_resource_id      = module.aks[0].id
  data_collection_rule_id = data.azurerm_monitor_data_collection_rule.aks_managed_prometheus[0].id
  description             = "Associates prod AKS with the Managed Prometheus data collection rule."

  depends_on = [
    azurerm_monitor_workspace.prod,
    module.aks,
  ]
}

resource "azurerm_role_assignment" "aks_prometheus_metrics_publisher" {
  count = var.enable_aks ? 1 : 0

  scope                = data.azurerm_monitor_data_collection_rule.aks_managed_prometheus[0].id
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id         = module.aks[0].kubelet_identity_object_id
}

resource "azurerm_role_assignment" "grafana_monitoring_reader" {
  scope                = azurerm_monitor_workspace.prod.id
  role_definition_name = "Monitoring Reader"
  principal_id         = azurerm_dashboard_grafana.prod.identity[0].principal_id
}

resource "azurerm_role_assignment" "grafana_log_analytics_reader" {
  scope                = module.monitor.log_analytics_workspace_id
  role_definition_name = "Log Analytics Reader"
  principal_id         = azurerm_dashboard_grafana.prod.identity[0].principal_id
}

resource "azurerm_role_assignment" "grafana_admin" {
  for_each = var.grafana_admin_principal_ids

  scope                = azurerm_dashboard_grafana.prod.id
  role_definition_name = "Grafana Admin"
  principal_id         = each.value
}

resource "azurerm_monitor_diagnostic_setting" "aks" {
  count = var.enable_aks ? 1 : 0

  name                       = "diag-${local.names.aks}"
  target_resource_id         = module.aks[0].id
  log_analytics_workspace_id = module.monitor.log_analytics_workspace_id

  enabled_log {
    category = "kube-audit-admin"
  }

  enabled_log {
    category = "kube-controller-manager"
  }

  enabled_log {
    category = "kube-scheduler"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_diagnostic_setting" "postgresql" {
  name                       = "diag-${local.names.postgresql}"
  target_resource_id         = module.postgresql.id
  log_analytics_workspace_id = module.monitor.log_analytics_workspace_id

  enabled_log {
    category = "PostgreSQLLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_diagnostic_setting" "service_bus" {
  name                       = "diag-${local.names.service_bus}"
  target_resource_id         = module.service_bus.namespace_id
  log_analytics_workspace_id = module.monitor.log_analytics_workspace_id

  enabled_log {
    category = "OperationalLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_action_group" "platform" {
  name                = local.names.action_group_platform
  resource_group_name = module.resource_group.name
  short_name          = "kairoprod"
  tags                = local.tags

  dynamic "email_receiver" {
    for_each = var.alert_email == "" ? [] : [var.alert_email]

    content {
      name          = "platform-email"
      email_address = email_receiver.value
    }
  }
}

resource "azurerm_monitor_metric_alert" "aks_node_cpu_high" {
  count = var.enable_aks ? 1 : 0

  name                = "alert-kairoai-prod-aks-node-cpu-high"
  resource_group_name = module.resource_group.name
  scopes              = [module.aks[0].id]
  description         = "AKS node CPU average is above 85 percent for 15 minutes."
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true
  tags                = local.tags

  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name      = "node_cpu_usage_percentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 85
  }

  action {
    action_group_id = azurerm_monitor_action_group.platform.id
  }
}

resource "azurerm_monitor_metric_alert" "aks_node_memory_high" {
  count = var.enable_aks ? 1 : 0

  name                = "alert-kairoai-prod-aks-node-memory-high"
  resource_group_name = module.resource_group.name
  scopes              = [module.aks[0].id]
  description         = "AKS node memory working set average is above 85 percent for 15 minutes."
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true
  tags                = local.tags

  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name      = "node_memory_working_set_percentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 85
  }

  action {
    action_group_id = azurerm_monitor_action_group.platform.id
  }
}

resource "azurerm_monitor_metric_alert" "postgres_cpu_high" {
  name                = "alert-kairoai-prod-postgres-cpu-high"
  resource_group_name = module.resource_group.name
  scopes              = [module.postgresql.id]
  description         = "PostgreSQL CPU is above 80 percent for 15 minutes."
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true
  tags                = local.tags

  criteria {
    metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
    metric_name      = "cpu_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.platform.id
  }
}

resource "azurerm_monitor_metric_alert" "postgres_storage_high" {
  name                = "alert-kairoai-prod-postgres-storage-high"
  resource_group_name = module.resource_group.name
  scopes              = [module.postgresql.id]
  description         = "PostgreSQL storage usage is above 80 percent for 15 minutes."
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true
  tags                = local.tags

  criteria {
    metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
    metric_name      = "storage_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.platform.id
  }
}
