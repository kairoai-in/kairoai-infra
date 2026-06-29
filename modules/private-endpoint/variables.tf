variable "name" {
  description = "Private endpoint name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group where the private endpoint is created."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the private endpoint network interface."
  type        = string
}

variable "private_connection_resource_id" {
  description = "Resource ID of the private link target."
  type        = string
}

variable "subresource_names" {
  description = "Private Link subresource/group IDs, for example ['vault'] for Key Vault."
  type        = list(string)
}

variable "private_dns_zone_ids" {
  description = "Private DNS zone IDs to attach to the endpoint."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default     = {}
}
