locals {
  region_code = "ci"

  names = {
    resource_group      = "rg-kairoai-test-ci"
    vnet                = "vnet-kairoai-test-ci"
    aks                 = "aks-kairoai-test-ci"
    app_gateway         = "agw-kairoai-test-ci"
    postgresql          = "psql-kairoai-test-ci"
    key_vault           = "kv-kairoai-test-ci"
    service_bus         = "sb-kairoai-test-ci"
    app_insights        = "appi-kairoai-test-ci"
    ai_foundry          = "oai-kairoai-test-ci"
    front_door_host     = "test.kairoai.in"
    front_door_api_host = "api.test.kairoai.in"
  }

  subnets = {
    "snet-aks-system"         = "10.20.0.0/22"
    "snet-aks-user"           = "10.20.16.0/21"
    "snet-app-gateway"        = "10.20.12.0/24"
    "snet-private-endpoints"  = "10.20.13.0/24"
    "snet-postgres-delegated" = "10.20.14.0/24"
    "snet-aci-private"        = "10.20.15.0/24"
  }

  hub_private_dns_zones_to_link = toset([
    "private.postgres.database.azure.com",
    "privatelink.azurecr.io",
    "privatelink.blob.core.windows.net",
    "privatelink.monitor.azure.com",
    "privatelink.ods.opinsights.azure.com",
    "privatelink.postgres.database.azure.com",
    "privatelink.servicebus.windows.net",
    "privatelink.vaultcore.azure.net",
  ])

  tags = merge(
    {
      application         = "kairoai"
      environment         = var.environment
      managed_by          = "terraform"
      owner               = "platform"
      cost_center         = "kairoai"
      data_classification = "internal"
      criticality         = "medium"
      region              = var.location
    },
    var.tags,
  )
}

data "azurerm_client_config" "current" {}

data "terraform_remote_state" "hub" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.hub_state_resource_group_name
    storage_account_name = var.hub_state_storage_account_name
    container_name       = var.hub_state_container_name
    key                  = var.hub_state_key
    subscription_id      = var.hub_subscription_id
    tenant_id            = var.tenant_id
  }
}

resource "azurerm_resource_group" "test" {
  name     = local.names.resource_group
  location = var.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "test" {
  name                = local.names.vnet
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = [var.vnet_cidr]
  tags                = local.tags
}

resource "azurerm_subnet" "test" {
  for_each = local.subnets

  name                 = each.key
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = [each.value]

  private_endpoint_network_policies = each.key == "snet-private-endpoints" ? "Disabled" : "Enabled"
  service_endpoints                 = each.key == "snet-postgres-delegated" ? ["Microsoft.Storage"] : []

  dynamic "delegation" {
    for_each = each.key == "snet-postgres-delegated" ? [1] : []

    content {
      name = "dlg-postgresql-flexible-server"

      service_delegation {
        name    = "Microsoft.DBforPostgreSQL/flexibleServers"
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    }
  }
}

resource "azurerm_virtual_network_peering" "test_to_hub" {
  name                         = "peer-${local.names.vnet}-to-${data.terraform_remote_state.hub.outputs.names.vnet}"
  resource_group_name          = azurerm_resource_group.test.name
  virtual_network_name         = azurerm_virtual_network.test.name
  remote_virtual_network_id    = data.terraform_remote_state.hub.outputs.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "hub_to_test" {
  provider = azurerm.hub

  name                         = "peer-${data.terraform_remote_state.hub.outputs.names.vnet}-to-${local.names.vnet}"
  resource_group_name          = data.terraform_remote_state.hub.outputs.resource_group_name
  virtual_network_name         = data.terraform_remote_state.hub.outputs.names.vnet
  remote_virtual_network_id    = azurerm_virtual_network.test.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "test" {
  provider = azurerm.hub
  for_each = local.hub_private_dns_zones_to_link

  name                  = "link-${replace(each.key, ".", "-")}-test"
  resource_group_name   = data.terraform_remote_state.hub.outputs.resource_group_name
  private_dns_zone_name = each.value
  virtual_network_id    = azurerm_virtual_network.test.id
  registration_enabled  = false
  tags                  = local.tags
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "law-kairoai-test-ci"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  tags                = local.tags
}

resource "azurerm_application_insights" "test" {
  name                = local.names.app_insights
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  workspace_id        = azurerm_log_analytics_workspace.test.id
  application_type    = "web"
  tags                = local.tags
}

resource "azurerm_key_vault" "test" {
  name                          = local.names.key_vault
  resource_group_name           = azurerm_resource_group.test.name
  location                      = azurerm_resource_group.test.location
  tenant_id                     = var.tenant_id
  sku_name                      = "standard"
  enable_rbac_authorization     = true
  purge_protection_enabled      = var.key_vault_purge_protection_enabled
  soft_delete_retention_days    = var.key_vault_soft_delete_retention_days
  public_network_access_enabled = var.public_network_access_enabled
  tags                          = local.tags
}

resource "azurerm_role_assignment" "test_key_vault_admin" {
  scope                = azurerm_key_vault.test.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_servicebus_namespace" "test" {
  name                = local.names.service_bus
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = var.service_bus_sku
  tags                = local.tags
}

resource "azurerm_servicebus_queue" "review_jobs" {
  name         = "review-jobs"
  namespace_id = azurerm_servicebus_namespace.test.id
}

resource "azurerm_servicebus_queue" "analysis_results" {
  name         = "analysis-results"
  namespace_id = azurerm_servicebus_namespace.test.id
}

resource "random_password" "postgres_admin" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_postgresql_flexible_server" "test" {
  name                          = local.names.postgresql
  resource_group_name           = azurerm_resource_group.test.name
  location                      = azurerm_resource_group.test.location
  version                       = var.postgres_version
  delegated_subnet_id           = azurerm_subnet.test["snet-postgres-delegated"].id
  private_dns_zone_id           = data.terraform_remote_state.hub.outputs.private_dns_zone_ids["private.postgres.database.azure.com"]
  public_network_access_enabled = false
  administrator_login           = "kairoaiadmin"
  administrator_password        = random_password.postgres_admin.result
  sku_name                      = var.postgres_sku_name
  storage_mb                    = var.postgres_storage_mb
  zone                          = "1"
  tags                          = local.tags

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.test,
  ]
}

resource "azurerm_postgresql_flexible_server_database" "app" {
  name      = "kairoai"
  server_id = azurerm_postgresql_flexible_server.test.id
  collation = "en_US.utf8"
  charset   = "UTF8"
}

resource "azurerm_key_vault_secret" "postgres_admin_password" {
  name         = "postgres-admin-password"
  value        = random_password.postgres_admin.result
  key_vault_id = azurerm_key_vault.test.id

  depends_on = [
    azurerm_role_assignment.test_key_vault_admin,
  ]
}
