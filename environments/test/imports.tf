import {
  to = azurerm_monitor_data_collection_rule_association.aks_managed_prometheus
  id = "/subscriptions/6b01db76-626a-44a2-8119-17682410914a/resourceGroups/rg-kairoai-test-ci/providers/Microsoft.ContainerService/managedClusters/aks-kairoai-test-ci/providers/Microsoft.Insights/dataCollectionRuleAssociations/ContainerInsightsMetricsExtension"
}

import {
  to = azurerm_role_assignment.aks_prometheus_metrics_publisher
  id = "/subscriptions/6b01db76-626a-44a2-8119-17682410914a/resourceGroups/rg-kairoai-test-ci/providers/Microsoft.Insights/dataCollectionRules/MSProm-centralindia-aks-kairoai-test-ci/providers/Microsoft.Authorization/roleAssignments/705dac2b-7b02-41e8-b7fa-b2f5267f03b8"
}
