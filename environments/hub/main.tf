locals {
  region_code = "ci"

  names = {
    resource_group             = "rg-kairoai-hub-ci"
    vnet                       = "vnet-kairoai-hub-ci"
    firewall                   = "afw-kairoai-hub-ci"
    firewall_policy            = "afwp-kairoai-hub-ci"
    bastion                    = "bas-kairoai-hub-ci"
    acr                        = "acrkairoaihubci"
    front_door                 = "afd-kairoai-global"
    public_dns_zone            = "kairoai.in"
    terraform_state_rg         = "rg-kairoai-tfstate-ci"
    terraform_state_storage    = "stkairoaitfstateci"
    terraform_state_containers = ["hubtfstate", "testtfstate", "prodtfstate"]
  }

  subnets = {
    AzureFirewallSubnet           = "10.10.0.0/26"
    AzureFirewallManagementSubnet = "10.10.0.64/26"
    AzureBastionSubnet            = "10.10.1.0/26"
    "snet-private-endpoints"      = "10.10.2.0/24"
    "snet-shared-services"        = "10.10.3.0/24"
  }

  private_dns_zones = toset([
    "privatelink.azurecr.io",
    "privatelink.blob.core.windows.net",
    "privatelink.monitor.azure.com",
    "privatelink.ods.opinsights.azure.com",
    "privatelink.postgres.database.azure.com",
    "privatelink.servicebus.windows.net",
    "privatelink.vaultcore.azure.net",
  ])

  cost_deferred_resources = {
    firewall   = local.names.firewall
    bastion    = local.names.bastion
    front_door = local.names.front_door
  }

  tags = merge(
    {
      application         = "kairoai"
      environment         = var.environment
      managed_by          = "terraform"
      owner               = "platform"
      cost_center         = "kairoai"
      data_classification = "internal"
      criticality         = "high"
      region              = var.location
    },
    var.tags,
  )
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "hub" {
  name     = local.names.resource_group
  location = var.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "hub" {
  name                = local.names.vnet
  resource_group_name = azurerm_resource_group.hub.name
  location            = azurerm_resource_group.hub.location
  address_space       = [var.vnet_cidr]
  tags                = local.tags
}

resource "azurerm_subnet" "hub" {
  for_each = local.subnets

  name                 = each.key
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [each.value]

  private_endpoint_network_policies = each.key == "snet-private-endpoints" ? "Disabled" : "Enabled"
}

resource "azurerm_dns_zone" "public" {
  name                = local.names.public_dns_zone
  resource_group_name = azurerm_resource_group.hub.name
  tags                = local.tags
}

resource "azurerm_private_dns_zone" "hub" {
  for_each = local.private_dns_zones

  name                = each.value
  resource_group_name = azurerm_resource_group.hub.name
  tags                = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "hub" {
  for_each = azurerm_private_dns_zone.hub

  name                  = "link-${replace(each.key, ".", "-")}-hub"
  resource_group_name   = azurerm_resource_group.hub.name
  private_dns_zone_name = each.value.name
  virtual_network_id    = azurerm_virtual_network.hub.id
  registration_enabled  = false
  tags                  = local.tags
}

resource "azurerm_container_registry" "hub" {
  name                = local.names.acr
  resource_group_name = azurerm_resource_group.hub.name
  location            = azurerm_resource_group.hub.location
  sku                 = var.acr_sku
  admin_enabled       = false
  tags                = local.tags
}

resource "azurerm_log_analytics_workspace" "hub" {
  name                = "law-kairoai-hub-ci"
  resource_group_name = azurerm_resource_group.hub.name
  location            = azurerm_resource_group.hub.location
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  tags                = local.tags
}

resource "azurerm_key_vault" "hub" {
  name                          = "kv-kairoai-hub-ci"
  resource_group_name           = azurerm_resource_group.hub.name
  location                      = azurerm_resource_group.hub.location
  tenant_id                     = var.tenant_id
  sku_name                      = "standard"
  enable_rbac_authorization     = true
  purge_protection_enabled      = var.key_vault_purge_protection_enabled
  soft_delete_retention_days    = var.key_vault_soft_delete_retention_days
  public_network_access_enabled = var.public_network_access_enabled
  tags                          = local.tags
}

resource "azurerm_role_assignment" "hub_key_vault_admin" {
  scope                = azurerm_key_vault.hub.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}
