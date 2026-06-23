terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      configuration_aliases = [azurerm.remote]
    }
  }
}

resource "azurerm_virtual_network_peering" "local_to_remote" {
  name                         = var.local_peering_name
  resource_group_name          = var.local_resource_group_name
  virtual_network_name         = var.local_vnet_name
  remote_virtual_network_id    = var.remote_vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "remote_to_local" {
  provider = azurerm.remote

  name                         = var.remote_peering_name
  resource_group_name          = var.remote_resource_group_name
  virtual_network_name         = var.remote_vnet_name
  remote_virtual_network_id    = var.local_vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}
