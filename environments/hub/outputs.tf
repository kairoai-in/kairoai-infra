output "names" {
  description = "Planned hub resource names."
  value       = local.names
}

output "vnet_cidr" {
  description = "Planned hub VNet CIDR."
  value       = var.vnet_cidr
}

output "subnets" {
  description = "Planned hub subnet CIDRs."
  value       = local.subnets
}
