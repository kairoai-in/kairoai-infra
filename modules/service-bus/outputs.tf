output "namespace_id" {
  description = "Service Bus namespace ID."
  value       = azurerm_servicebus_namespace.this.id
}

output "queue_ids" {
  description = "Service Bus queue IDs keyed by queue name."
  value       = { for name, queue in azurerm_servicebus_queue.this : name => queue.id }
}
