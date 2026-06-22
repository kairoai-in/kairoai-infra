variable "subscription_id" {
  description = "Test subscription ID."
  type        = string
  default     = "6b01db76-626a-44a2-8119-17682410914a"
}

variable "hub_subscription_id" {
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

variable "hub_state_resource_group_name" {
  description = "Resource group containing hub Terraform state."
  type        = string
  default     = "rg-kairoai-tfstate-ci"
}

variable "hub_state_storage_account_name" {
  description = "Storage account containing hub Terraform state."
  type        = string
  default     = "stkairoaitfstateci"
}

variable "hub_state_container_name" {
  description = "Blob container containing hub Terraform state."
  type        = string
  default     = "hubtfstate"
}

variable "hub_state_key" {
  description = "Hub Terraform state key."
  type        = string
  default     = "kairoai/hub/terraform.tfstate"
}

variable "log_retention_days" {
  description = "Log Analytics retention in days."
  type        = number
  default     = 30
}

variable "key_vault_purge_protection_enabled" {
  description = "Enable purge protection for the test Key Vault."
  type        = bool
  default     = true
}

variable "key_vault_soft_delete_retention_days" {
  description = "Soft delete retention for the test Key Vault."
  type        = number
  default     = 30
}

variable "public_network_access_enabled" {
  description = "Allow public network access during the bootstrap phase. Private endpoints will harden this later."
  type        = bool
  default     = true
}

variable "postgres_version" {
  description = "Azure PostgreSQL Flexible Server major version."
  type        = string
  default     = "16"
}

variable "postgres_sku_name" {
  description = "Azure PostgreSQL Flexible Server SKU."
  type        = string
  default     = "B_Standard_B1ms"
}

variable "postgres_storage_mb" {
  description = "Azure PostgreSQL Flexible Server storage in MB."
  type        = number
  default     = 32768
}

variable "service_bus_sku" {
  description = "Azure Service Bus namespace SKU."
  type        = string
  default     = "Standard"
}
