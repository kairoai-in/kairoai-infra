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

variable "aks_kubernetes_version" {
  description = "AKS Kubernetes version. Null lets Azure choose the default stable version."
  type        = string
  default     = null
}

variable "aks_system_node_min_count" {
  description = "Minimum node count for the autoscaled AKS system node pool."
  type        = number
  default     = 1
}

variable "aks_system_node_max_count" {
  description = "Maximum node count for the autoscaled AKS system node pool."
  type        = number
  default     = 2
}

variable "aks_system_node_vm_size" {
  description = "VM size for the AKS system node pool."
  type        = string
  default     = "Standard_D2s_v4"
}

variable "aks_user_node_min_count" {
  description = "Minimum node count for the autoscaled AKS user node pool."
  type        = number
  default     = 1
}

variable "aks_user_node_max_count" {
  description = "Maximum node count for the autoscaled AKS user node pool."
  type        = number
  default     = 3
}

variable "aks_user_node_vm_size" {
  description = "VM size for the AKS user node pool."
  type        = string
  default     = "Standard_D2s_v4"
}

variable "aks_private_cluster_enabled" {
  description = "Enable a private AKS API endpoint."
  type        = bool
  default     = true
}

variable "grafana_public_network_access_enabled" {
  description = "Allow public access to Azure Managed Grafana during the test bootstrap phase."
  type        = bool
  default     = true
}

variable "alert_email" {
  description = "Optional email receiver for Azure Monitor alerts. Leave empty to create the action group without email receivers."
  type        = string
  default     = ""
}
