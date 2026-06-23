module "app_gateway_waf" {
  source = "../../modules/app-gateway-waf"
  count  = var.enable_app_gateway_waf ? 1 : 0

  name                       = local.names.app_gateway
  public_ip_name             = local.names.public_ip
  resource_group_name        = module.resource_group.name
  location                   = module.resource_group.location
  subnet_id                  = module.networking.subnet_ids["snet-app-gateway"]
  min_capacity               = var.app_gateway_min_capacity
  max_capacity               = var.app_gateway_max_capacity
  log_analytics_workspace_id = module.monitor.log_analytics_workspace_id
  action_group_id            = azurerm_monitor_action_group.platform.id
  tags                       = local.tags
}

module "ai_foundry" {
  source = "../../modules/ai-foundry"
  count  = var.enable_ai_foundry ? 1 : 0

  name                          = local.names.ai_foundry
  resource_group_name           = module.resource_group.name
  location                      = module.resource_group.location
  sku_name                      = var.ai_foundry_sku_name
  custom_subdomain_name         = local.names.ai_foundry
  public_network_access_enabled = var.public_network_access_enabled
  deployments                   = var.ai_foundry_deployments
  tags                          = local.tags
}

module "managed_identity" {
  source   = "../../modules/managed-identity"
  for_each = var.managed_identities

  name                  = "id-${local.names.resource_group}-${each.key}"
  resource_group_name   = module.resource_group.name
  location              = module.resource_group.location
  federated_credentials = each.value.federated_credentials
  role_assignments      = each.value.role_assignments
  tags                  = local.tags
}

module "policy" {
  source = "../../modules/policy"

  assignments = {
    for name, assignment in var.policy_assignments : name => merge(
      assignment,
      {
        resource_id = module.resource_group.id
      },
    )
  }
}
