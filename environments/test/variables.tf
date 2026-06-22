variable "subscription_id" {
  description = "Test subscription ID."
  type        = string
  default     = "6b01db76-626a-44a2-8119-17682410914a"
}

variable "tenant_id" {
  description = "Azure tenant ID."
  type        = string
  default     = "83474cb5-f1fa-4d06-906c-e5dad12ce3b9"
}

variable "location" {
  description = "Primary Azure region."
  type        = string
  default     = "centralindia"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "test"
}

variable "vnet_cidr" {
  description = "Test spoke VNet CIDR."
  type        = string
  default     = "10.20.0.0/16"
}

variable "tags" {
  description = "Additional tags."
  type        = map(string)
  default     = {}
}
