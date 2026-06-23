data "azurerm_container_registry" "hub" {
  provider            = azurerm.hub
  name                = data.terraform_remote_state.hub.outputs.names.acr
  resource_group_name = data.terraform_remote_state.hub.outputs.resource_group_name
}

module "aks" {
  source = "../../modules/aks"

  name                       = local.names.aks
  resource_group_name        = module.resource_group.name
  location                   = module.resource_group.location
  dns_prefix                 = "aks-kairoai-test"
  node_resource_group        = "rg-kairoai-test-ci-aks-nodes"
  kubernetes_version         = var.aks_kubernetes_version
  tenant_id                  = var.tenant_id
  private_cluster_enabled    = var.aks_private_cluster_enabled
  system_subnet_id           = module.networking.subnet_ids["snet-aks-system"]
  user_subnet_id             = module.networking.subnet_ids["snet-aks-user"]
  log_analytics_workspace_id = module.monitor.log_analytics_workspace_id
  acr_id                     = data.azurerm_container_registry.hub.id
  key_vault_id               = module.key_vault.id
  system_node_vm_size        = var.aks_system_node_vm_size
  system_node_min_count      = var.aks_system_node_min_count
  system_node_max_count      = var.aks_system_node_max_count
  user_node_vm_size          = var.aks_user_node_vm_size
  user_node_min_count        = var.aks_user_node_min_count
  user_node_max_count        = var.aks_user_node_max_count
  tags                       = local.tags
}
