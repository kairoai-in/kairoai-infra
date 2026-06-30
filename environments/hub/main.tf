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
    front_door_endpoint        = "fde-kairoai-global"
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
    "private.postgres.database.azure.com",
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

data "terraform_remote_state" "test" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.test_state_resource_group_name
    storage_account_name = var.test_state_storage_account_name
    container_name       = var.test_state_container_name
    key                  = var.test_state_key
    subscription_id      = var.subscription_id
    tenant_id            = var.tenant_id
  }
}

data "terraform_remote_state" "prod" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.prod_state_resource_group_name
    storage_account_name = var.prod_state_storage_account_name
    container_name       = var.prod_state_container_name
    key                  = var.prod_state_key
    subscription_id      = var.subscription_id
    tenant_id            = var.tenant_id
  }
}

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

resource "azurerm_monitor_action_group" "hub" {
  name                = "ag-kairoai-hub-platform"
  resource_group_name = azurerm_resource_group.hub.name
  short_name          = "kairohub"
  tags                = local.tags

  dynamic "email_receiver" {
    for_each = var.alert_email == "" ? [] : [var.alert_email]

    content {
      name          = "platform-email"
      email_address = email_receiver.value
    }
  }
}

resource "azurerm_key_vault" "hub" {
  name                          = "kv-kairoai-hub-ci"
  resource_group_name           = azurerm_resource_group.hub.name
  location                      = azurerm_resource_group.hub.location
  tenant_id                     = var.tenant_id
  sku_name                      = "standard"
  rbac_authorization_enabled    = true
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

module "hub_key_vault_private_endpoint" {
  source = "../../modules/private-endpoint"

  name                           = "pe-${azurerm_key_vault.hub.name}"
  resource_group_name            = azurerm_resource_group.hub.name
  location                       = azurerm_resource_group.hub.location
  subnet_id                      = azurerm_subnet.hub["snet-private-endpoints"].id
  private_connection_resource_id = azurerm_key_vault.hub.id
  subresource_names              = ["vault"]
  private_dns_zone_ids           = [azurerm_private_dns_zone.hub["privatelink.vaultcore.azure.net"].id]
  tags                           = local.tags

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.hub,
  ]
}

module "front_door" {
  source = "../../modules/front-door"

  profile_name        = local.names.front_door
  endpoint_name       = local.names.front_door_endpoint
  resource_group_name = azurerm_resource_group.hub.name
  sku_name            = var.front_door_sku_name
  dns_zone_id         = azurerm_dns_zone.public.id
  routes = {
    prod-dashboard = {
      host_name          = "kairoai.in"
      origin_host_name   = data.terraform_remote_state.prod.outputs.app_gateway_public_ip_address
      origin_host_header = "kairoai.in"
    }
    prod-api = {
      host_name          = "api.kairoai.in"
      origin_host_name   = data.terraform_remote_state.prod.outputs.app_gateway_public_ip_address
      origin_host_header = "api.kairoai.in"
    }
    test-dashboard = {
      host_name          = "test.kairoai.in"
      origin_host_name   = data.terraform_remote_state.test.outputs.app_gateway_public_ip_address
      origin_host_header = "test.kairoai.in"
    }
    test-api = {
      host_name          = "test-api.kairoai.in"
      origin_host_name   = data.terraform_remote_state.test.outputs.app_gateway_public_ip_address
      origin_host_header = "test-api.kairoai.in"
    }
    test-argocd = {
      host_name          = "test-argocd.kairoai.in"
      origin_host_name   = data.terraform_remote_state.test.outputs.app_gateway_public_ip_address
      origin_host_header = "test-argocd.kairoai.in"
      health_probe_path  = "/healthz"
    }
    prod-argocd = {
      host_name          = "prod-argocd.kairoai.in"
      origin_host_name   = data.terraform_remote_state.prod.outputs.app_gateway_public_ip_address
      origin_host_header = "prod-argocd.kairoai.in"
      health_probe_path  = "/healthz"
    }
  }
  log_analytics_workspace_id = azurerm_log_analytics_workspace.hub.id
  action_group_id            = azurerm_monitor_action_group.hub.id
  metric_alerts_enabled      = true
  tags                       = local.tags
}

resource "azurerm_dns_a_record" "front_door_apex" {
  name                = "@"
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = azurerm_resource_group.hub.name
  ttl                 = 300
  target_resource_id  = module.front_door.endpoint_id
  tags                = local.tags
}

resource "azurerm_dns_cname_record" "front_door_subdomains" {
  for_each = {
    api         = "api"
    test        = "test"
    test-api    = "test-api"
    test-argocd = "test-argocd"
    prod-argocd = "prod-argocd"
  }

  name                = each.value
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = azurerm_resource_group.hub.name
  ttl                 = 300
  record              = module.front_door.endpoint_host_name
  tags                = local.tags
}

resource "azurerm_dns_txt_record" "front_door_domain_validation" {
  for_each = {
    "_dnsauth"             = module.front_door.custom_domain_validation_tokens["prod-dashboard"]
    "_dnsauth.api"         = module.front_door.custom_domain_validation_tokens["prod-api"]
    "_dnsauth.test"        = module.front_door.custom_domain_validation_tokens["test-dashboard"]
    "_dnsauth.test-api"    = module.front_door.custom_domain_validation_tokens["test-api"]
    "_dnsauth.test-argocd" = module.front_door.custom_domain_validation_tokens["test-argocd"]
    "_dnsauth.prod-argocd" = module.front_door.custom_domain_validation_tokens["prod-argocd"]
  }

  name                = each.key
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = azurerm_resource_group.hub.name
  ttl                 = 300
  tags                = local.tags

  record {
    value = each.value
  }
}
