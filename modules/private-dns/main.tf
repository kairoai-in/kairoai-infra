terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each = var.zone_names

  name                  = "${var.link_name_prefix}-${replace(each.key, ".", "-")}${var.link_name_suffix}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = each.value
  virtual_network_id    = var.virtual_network_id
  registration_enabled  = var.registration_enabled
  tags                  = var.tags
}
