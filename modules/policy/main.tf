terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

resource "azurerm_resource_policy_assignment" "this" {
  for_each = var.assignments

  name                 = each.key
  resource_id          = each.value.resource_id
  policy_definition_id = each.value.policy_definition_id
  display_name         = each.value.display_name
  description          = each.value.description
  parameters           = each.value.parameters
  location             = each.value.location

  dynamic "identity" {
    for_each = each.value.identity_type == null ? [] : [each.value.identity_type]

    content {
      type = identity.value
    }
  }
}
