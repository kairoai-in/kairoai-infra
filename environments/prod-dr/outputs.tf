output "names" {
  description = "Planned prod DR resource names."
  value       = local.names
}

output "vnet_cidr" {
  description = "Planned prod DR VNet CIDR."
  value       = var.vnet_cidr
}

output "subnets" {
  description = "Planned prod DR subnet CIDRs."
  value       = local.subnets
}
