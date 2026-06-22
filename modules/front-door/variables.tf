variable "profile_name" {
  description = "Azure Front Door profile name."
  type        = string
}

variable "endpoint_name" {
  description = "Azure Front Door endpoint name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "sku_name" {
  description = "Front Door SKU."
  type        = string
  default     = "Premium_AzureFrontDoor"
}

variable "origin_host_name" {
  description = "Origin host name, normally Application Gateway public IP DNS or frontend host."
  type        = string
}

variable "origin_host_header" {
  description = "Host header sent to the origin."
  type        = string
}

variable "patterns_to_match" {
  description = "Route path patterns."
  type        = list(string)
  default     = ["/*"]
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
