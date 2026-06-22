terraform {
  required_version = ">= 1.8.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.116"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id

  features {}
}

data "azurerm_client_config" "current" {}

locals {
  tags = merge(
    {
      application         = "kairoai"
      environment         = "hub"
      managed_by          = "terraform"
      owner               = "platform"
      cost_center         = "kairoai"
      data_classification = "confidential"
      criticality         = "high"
      region              = var.location
    },
    var.tags,
  )
}

resource "azurerm_resource_group" "state" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.tags
}

resource "azurerm_storage_account" "state" {
  name                            = var.storage_account_name
  resource_group_name             = azurerm_resource_group.state.name
  location                        = azurerm_resource_group.state.location
  account_tier                    = "Standard"
  account_replication_type        = var.account_replication_type
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = var.public_network_access_enabled
  shared_access_key_enabled       = true

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = var.blob_delete_retention_days
    }

    container_delete_retention_policy {
      days = var.container_delete_retention_days
    }
  }

  tags = local.tags
}

resource "azurerm_storage_container" "state" {
  for_each              = toset(var.container_names)
  name                  = each.value
  storage_account_name  = azurerm_storage_account.state.name
  container_access_type = "private"
}

resource "azurerm_role_assignment" "state_blob_data_contributor" {
  for_each             = toset(concat([data.azurerm_client_config.current.object_id], var.state_blob_data_contributor_object_ids))
  scope                = azurerm_storage_account.state.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = each.value
}
