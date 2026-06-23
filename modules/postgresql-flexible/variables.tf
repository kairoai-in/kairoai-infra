variable "name" {
  description = "PostgreSQL Flexible Server name."
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

variable "server_version" {
  description = "PostgreSQL major version."
  type        = string
  default     = "16"
}

variable "delegated_subnet_id" {
  description = "Delegated subnet ID."
  type        = string
}

variable "private_dns_zone_id" {
  description = "Private DNS zone ID."
  type        = string
}

variable "administrator_login" {
  description = "PostgreSQL administrator login."
  type        = string
  default     = "kairoaiadmin"
}

variable "sku_name" {
  description = "PostgreSQL Flexible Server SKU."
  type        = string
}

variable "storage_mb" {
  description = "Storage size in MB."
  type        = number
}

variable "zone" {
  description = "Availability zone."
  type        = string
  default     = "1"
}

variable "database_name" {
  description = "Application database name."
  type        = string
  default     = "kairoai"
}

variable "key_vault_id" {
  description = "Key Vault ID where generated admin password is stored."
  type        = string
}

variable "key_vault_secret_name" {
  description = "Secret name for generated admin password."
  type        = string
  default     = "postgres-admin-password"
}

variable "database_url_secret_name" {
  description = "Key Vault secret name for the generated SQLAlchemy database URL."
  type        = string
  default     = "database-url"
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
