resource "azurerm_resource_group" "this" {
  name     = "rg-${var.name_prefix}-${var.environment}"
  location = var.location
}
