terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

resource "azurerm_servicebus_namespace" "this" {
  name                         = var.name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  sku                          = var.sku
  capacity                     = var.sku == "Premium" ? var.capacity : 0
  premium_messaging_partitions = var.sku == "Premium" ? var.premium_messaging_partitions : 0
  tags                         = var.tags
}

resource "azurerm_servicebus_queue" "this" {
  for_each = var.queues

  name         = each.value
  namespace_id = azurerm_servicebus_namespace.this.id
}
