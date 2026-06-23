# Smoke PRs may touch this file to exercise the protected test pipeline and apply gate.
locals {
  region_code = "ci"
  names       = module.naming.names

  subnets = {
    "snet-aks-system" = {
      address_prefixes = ["10.20.0.0/22"]
    }
    "snet-aks-user" = {
      address_prefixes = ["10.20.16.0/21"]
    }
    "snet-app-gateway" = {
      address_prefixes = ["10.20.12.0/24"]
    }
    "snet-private-endpoints" = {
      address_prefixes                  = ["10.20.13.0/24"]
      private_endpoint_network_policies = "Disabled"
    }
    "snet-postgres-delegated" = {
      address_prefixes           = ["10.20.14.0/24"]
      service_endpoints          = ["Microsoft.Storage"]
      delegation_name            = "dlg-postgresql-flexible-server"
      delegation_service_name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      delegation_service_actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
    "snet-aci-private" = {
      address_prefixes = ["10.20.15.0/24"]
    }
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

module "naming" {
  source = "../../modules/naming"

  workload    = "kairoai"
  environment = var.environment
  region_code = local.region_code
}

module "resource_group" {
  source = "../../modules/resource-group"

  name     = local.names.resource_group
  location = var.location
  tags     = local.tags
}

module "networking" {
  source = "../../modules/networking"

  name                = local.names.vnet
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  address_space       = [var.vnet_cidr]
  subnets             = local.subnets
  tags                = local.tags
}

module "vnet_peering" {
  source = "../../modules/vnet-peering"

  providers = {
    azurerm.remote = azurerm.hub
  }

  local_peering_name         = "peer-${local.names.vnet}-to-${data.terraform_remote_state.hub.outputs.names.vnet}"
  remote_peering_name        = "peer-${data.terraform_remote_state.hub.outputs.names.vnet}-to-${local.names.vnet}"
  local_resource_group_name  = module.resource_group.name
  local_vnet_name            = module.networking.vnet_name
  local_vnet_id              = module.networking.vnet_id
  remote_resource_group_name = data.terraform_remote_state.hub.outputs.resource_group_name
  remote_vnet_name           = data.terraform_remote_state.hub.outputs.names.vnet
  remote_vnet_id             = data.terraform_remote_state.hub.outputs.vnet_id
}

module "private_dns_links" {
  source = "../../modules/private-dns"

  providers = {
    azurerm = azurerm.hub
  }

  zone_names          = local.hub_private_dns_zones_to_link
  resource_group_name = data.terraform_remote_state.hub.outputs.resource_group_name
  virtual_network_id  = module.networking.vnet_id
  link_name_prefix    = "link"
  link_name_suffix    = "-test"
  tags                = local.tags
}

module "monitor" {
  source = "../../modules/monitor"

  log_analytics_name        = local.names.log_analytics
  application_insights_name = local.names.app_insights
  resource_group_name       = module.resource_group.name
  location                  = module.resource_group.location
  retention_in_days         = var.log_retention_days
  tags                      = local.tags
}

module "key_vault" {
  source = "../../modules/key-vault"

  name                          = local.names.key_vault
  resource_group_name           = module.resource_group.name
  location                      = module.resource_group.location
  tenant_id                     = var.tenant_id
  admin_principal_id            = data.azurerm_client_config.current.object_id
  purge_protection_enabled      = var.key_vault_purge_protection_enabled
  soft_delete_retention_days    = var.key_vault_soft_delete_retention_days
  public_network_access_enabled = var.public_network_access_enabled
  tags                          = local.tags
}

module "service_bus" {
  source = "../../modules/service-bus"

  name                = local.names.service_bus
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  sku                 = var.service_bus_sku
  queues              = ["review-analysis", "review-jobs", "analysis-results"]
  authorization_rules = {
    review-runtime = {
      queue_name = "review-analysis"
      listen     = true
      send       = true
    }
  }
  tags = local.tags
}

resource "azurerm_key_vault_secret" "service_bus_connection_string" {
  name         = "service-bus-connection-string"
  value        = module.service_bus.authorization_rule_primary_connection_strings["review-runtime"]
  key_vault_id = module.key_vault.id
}

module "postgresql" {
  source = "../../modules/postgresql-flexible"

  name                = local.names.postgresql
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  server_version      = var.postgres_version
  delegated_subnet_id = module.networking.subnet_ids["snet-postgres-delegated"]
  private_dns_zone_id = data.terraform_remote_state.hub.outputs.private_dns_zone_ids["private.postgres.database.azure.com"]
  sku_name            = var.postgres_sku_name
  storage_mb          = var.postgres_storage_mb
  key_vault_id        = module.key_vault.id
  tags                = local.tags

  depends_on = [
    module.private_dns_links,
    module.key_vault,
  ]
}
