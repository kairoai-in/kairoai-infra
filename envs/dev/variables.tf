variable "location" {
  description = "Azure region for the dev environment."
  type        = string
  default     = "eastus"
}

variable "name_prefix" {
  description = "Prefix for KairoAI Azure resources."
  type        = string
  default     = "kairoai"
}
