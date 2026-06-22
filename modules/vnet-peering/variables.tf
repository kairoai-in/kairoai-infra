variable "local_peering_name" {
  description = "Peering name created on the local VNet."
  type        = string
}

variable "remote_peering_name" {
  description = "Peering name created on the remote VNet."
  type        = string
}

variable "local_resource_group_name" {
  description = "Resource group containing the local VNet."
  type        = string
}

variable "local_vnet_name" {
  description = "Local VNet name."
  type        = string
}

variable "local_vnet_id" {
  description = "Local VNet ID."
  type        = string
}

variable "remote_resource_group_name" {
  description = "Resource group containing the remote VNet."
  type        = string
}

variable "remote_vnet_name" {
  description = "Remote VNet name."
  type        = string
}

variable "remote_vnet_id" {
  description = "Remote VNet ID."
  type        = string
}
