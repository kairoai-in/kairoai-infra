output "assignment_ids" {
  description = "Policy assignment IDs keyed by assignment name."
  value       = { for name, assignment in azurerm_resource_policy_assignment.this : name => assignment.id }
}
