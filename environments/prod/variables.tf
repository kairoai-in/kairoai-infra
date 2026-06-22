variable "subscription_id" {
  description = "Production subscription ID."
  type        = string
  default     = "a8270be7-dabc-4d92-98db-26a55025b0df"
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
  default     = "prod"
}

variable "vnet_cidr" {
  description = "Prod spoke VNet CIDR."
  type        = string
  default     = "10.30.0.0/16"
}

variable "tags" {
  description = "Additional tags."
  type        = map(string)
  default     = {}
}
