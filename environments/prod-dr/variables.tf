variable "subscription_id" {
  description = "Production subscription ID used for DR resources."
  type        = string
  default     = "a8270be7-dabc-4d92-98db-26a55025b0df"
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
  description = "DR Azure region."
  type        = string
  default     = "southindia"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "prod-dr"
}

variable "vnet_cidr" {
  description = "Prod DR spoke VNet CIDR."
  type        = string
  default     = "10.40.0.0/16"
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
  default     = 90
}

variable "alert_email" {
  description = "Optional email receiver for Azure Monitor alerts. Leave empty to create the action group without email receivers."
  type        = string
  default     = ""
}

variable "key_vault_purge_protection_enabled" {
  description = "Enable purge protection for the DR Key Vault."
  type        = bool
  default     = true
}

variable "key_vault_soft_delete_retention_days" {
  description = "Soft delete retention for the DR Key Vault."
  type        = number
  default     = 90
}

variable "public_network_access_enabled" {
  description = "Allow public network access during bootstrap. Private endpoints should harden this before production traffic."
  type        = bool
  default     = true
}

variable "enable_postgresql" {
  description = "Create DR PostgreSQL Flexible Server foundation."
  type        = bool
  default     = false
}

variable "postgres_version" {
  description = "Azure PostgreSQL Flexible Server major version."
  type        = string
  default     = "16"
}

variable "postgres_sku_name" {
  description = "Azure PostgreSQL Flexible Server SKU."
  type        = string
  default     = "GP_Standard_D2s_v3"
}

variable "postgres_storage_mb" {
  description = "Azure PostgreSQL Flexible Server storage in MB."
  type        = number
  default     = 131072
}

variable "enable_service_bus" {
  description = "Create optional DR Service Bus namespace."
  type        = bool
  default     = false
}

variable "service_bus_sku" {
  description = "Azure Service Bus namespace SKU."
  type        = string
  default     = "Premium"
}

variable "service_bus_capacity" {
  description = "Messaging unit capacity for Premium Service Bus namespaces."
  type        = number
  default     = 1
}

variable "service_bus_premium_messaging_partitions" {
  description = "Premium messaging partitions for Premium Service Bus namespaces."
  type        = number
  default     = 1
}

variable "enable_aks" {
  description = "Create optional warm standby DR AKS."
  type        = bool
  default     = false
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

variable "enable_app_gateway_waf" {
  description = "Create optional DR Application Gateway WAF."
  type        = bool
  default     = false
}

variable "enable_ai_foundry" {
  description = "Create optional DR Azure AI Services / AI Foundry account."
  type        = bool
  default     = false
}

variable "app_gateway_min_capacity" {
  description = "Minimum Application Gateway autoscale capacity."
  type        = number
  default     = 1
}

variable "app_gateway_max_capacity" {
  description = "Maximum Application Gateway autoscale capacity."
  type        = number
  default     = 2
}

variable "ai_foundry_sku_name" {
  description = "Azure AI Services SKU."
  type        = string
  default     = "S0"
}

variable "ai_foundry_deployments" {
  description = "Azure AI model deployments keyed by deployment name."
  type = map(object({
    model_format  = optional(string, "OpenAI")
    model_name    = string
    model_version = string
    sku_name      = optional(string, "Standard")
    capacity      = optional(number, 1)
  }))
  default = {}
}

variable "managed_identities" {
  description = "User-assigned managed identities to create, keyed by short name."
  type = map(object({
    federated_credentials = optional(map(object({
      issuer    = string
      subject   = string
      audiences = optional(list(string), ["api://AzureADTokenExchange"])
    })), {})
    role_assignments = optional(map(object({
      scope                = string
      role_definition_name = string
    })), {})
  }))
  default = {}
}

variable "policy_assignments" {
  description = "Azure Policy assignments for the DR resource group."
  type = map(object({
    policy_definition_id = string
    display_name         = string
    description          = optional(string, null)
    parameters           = optional(string, null)
    location             = optional(string, null)
    identity_type        = optional(string, null)
  }))
  default = {}
}
