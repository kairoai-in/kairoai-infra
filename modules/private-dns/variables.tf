variable "zone_names" {
  description = "Private DNS zone names to link."
  type        = set(string)
}

variable "resource_group_name" {
  description = "Resource group containing the private DNS zones."
  type        = string
}

variable "virtual_network_id" {
  description = "Virtual network ID to link."
  type        = string
}

variable "link_name_prefix" {
  description = "Prefix used for DNS VNet link names."
  type        = string
}

variable "link_name_suffix" {
  description = "Optional suffix used for DNS VNet link names."
  type        = string
  default     = ""
}

variable "registration_enabled" {
  description = "Enable auto-registration."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
