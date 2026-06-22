output "names" {
  description = "Planned prod resource names."
  value       = local.names
}

output "vnet_cidr" {
  description = "Planned prod VNet CIDR."
  value       = var.vnet_cidr
}

output "subnets" {
  description = "Planned prod subnet CIDRs."
  value       = local.subnets
}
