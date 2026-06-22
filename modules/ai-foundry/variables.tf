variable "name" {
  description = "Azure AI Services account name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "sku_name" {
  description = "Azure AI Services SKU."
  type        = string
  default     = "S0"
}

variable "custom_subdomain_name" {
  description = "Custom subdomain for Azure AI Services."
  type        = string
}

variable "public_network_access_enabled" {
  description = "Allow public network access."
  type        = bool
  default     = true
}

variable "deployments" {
  description = "Azure OpenAI model deployments keyed by deployment name."
  type = map(object({
    model_format  = optional(string, "OpenAI")
    model_name    = string
    model_version = string
    sku_name      = optional(string, "Standard")
    capacity      = optional(number, 1)
  }))
  default = {}
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
