output "namespace_id" {
  description = "Service Bus namespace ID."
  value       = azurerm_servicebus_namespace.this.id
}

output "queue_ids" {
  description = "Service Bus queue IDs keyed by queue name."
  value       = { for name, queue in azurerm_servicebus_queue.this : name => queue.id }
}

output "authorization_rule_primary_connection_strings" {
  description = "Primary connection strings keyed by queue authorization rule name."
  value = {
    for name, rule in azurerm_servicebus_queue_authorization_rule.this : name => rule.primary_connection_string
  }
  sensitive = true
}
