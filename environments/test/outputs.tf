output "names" {
  description = "Planned test resource names."
  value       = local.names
}

output "vnet_cidr" {
  description = "Planned test VNet CIDR."
  value       = var.vnet_cidr
}

output "subnets" {
  description = "Planned test subnet CIDRs."
  value       = local.subnets
}
