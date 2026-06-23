variable "subscription_id" {
  description = "Hub subscription ID."
  type        = string
  default     = "5b942f88-17e6-4026-ae23-d520365fb916"
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
  default     = "hub"
}

variable "vnet_cidr" {
  description = "Hub VNet CIDR."
  type        = string
  default     = "10.10.0.0/16"
}

variable "tags" {
  description = "Additional tags."
  type        = map(string)
  default     = {}
}

variable "acr_sku" {
  description = "Hub Azure Container Registry SKU. Premium is required for private endpoints."
  type        = string
  default     = "Premium"
}

variable "log_retention_days" {
  description = "Log Analytics retention in days."
  type        = number
  default     = 30
}

variable "key_vault_purge_protection_enabled" {
  description = "Enable purge protection for the hub Key Vault."
  type        = bool
  default     = true
}

variable "key_vault_soft_delete_retention_days" {
  description = "Soft delete retention for the hub Key Vault."
  type        = number
  default     = 30
}

variable "public_network_access_enabled" {
  description = "Allow public network access during the bootstrap phase. Private endpoints will harden this later."
  type        = bool
  default     = true
}

variable "test_state_resource_group_name" {
  description = "Resource group containing test Terraform state."
  type        = string
  default     = "rg-kairoai-tfstate-ci"
}

variable "test_state_storage_account_name" {
  description = "Storage account containing test Terraform state."
  type        = string
  default     = "stkairoaitfstateci"
}

variable "test_state_container_name" {
  description = "Blob container containing test Terraform state."
  type        = string
  default     = "testtfstate"
}

variable "test_state_key" {
  description = "Test Terraform state key."
  type        = string
  default     = "kairoai/test/terraform.tfstate"
}

variable "prod_state_resource_group_name" {
  description = "Resource group containing prod Terraform state."
  type        = string
  default     = "rg-kairoai-tfstate-ci"
}

variable "prod_state_storage_account_name" {
  description = "Storage account containing prod Terraform state."
  type        = string
  default     = "stkairoaitfstateci"
}

variable "prod_state_container_name" {
  description = "Blob container containing prod Terraform state."
  type        = string
  default     = "prodtfstate"
}

variable "prod_state_key" {
  description = "Prod Terraform state key."
  type        = string
  default     = "kairoai/prod/terraform.tfstate"
}

variable "front_door_sku_name" {
  description = "Shared Azure Front Door SKU."
  type        = string
  default     = "Premium_AzureFrontDoor"
}

variable "alert_email" {
  description = "Optional email receiver for hub/shared alerts."
  type        = string
  default     = ""
}
