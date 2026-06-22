output "link_ids" {
  description = "Private DNS VNet link IDs keyed by zone name."
  value       = { for zone, link in azurerm_private_dns_zone_virtual_network_link.this : zone => link.id }
}
