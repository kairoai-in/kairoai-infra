resource "azurerm_monitor_action_group" "platform" {
  name                = local.names.action_group_platform
  resource_group_name = module.resource_group.name
  short_name          = "kairoprod"
  tags                = local.tags

  dynamic "email_receiver" {
    for_each = var.alert_email == "" ? [] : [var.alert_email]

    content {
      name          = "platform-email"
      email_address = email_receiver.value
    }
  }
}
