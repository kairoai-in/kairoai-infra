variable "name" {
  description = "AKS cluster name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name for the AKS cluster."
  type        = string
}

variable "location" {
  description = "Azure region for the AKS cluster."
  type        = string
}

variable "dns_prefix" {
  description = "AKS DNS prefix."
  type        = string
}

variable "node_resource_group" {
  description = "AKS managed node resource group name."
  type        = string
}

variable "kubernetes_version" {
  description = "AKS Kubernetes version. Null lets Azure choose the default stable version."
  type        = string
  default     = null
}

variable "tenant_id" {
  description = "Azure tenant ID for managed AAD integration."
  type        = string
}

variable "private_cluster_enabled" {
  description = "Enable a private AKS API endpoint."
  type        = bool
  default     = true
}

variable "system_subnet_id" {
  description = "Subnet ID for the system node pool."
  type        = string
}

variable "user_subnet_id" {
  description = "Subnet ID for the user node pool."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for AKS monitoring."
  type        = string
}

variable "acr_id" {
  description = "Azure Container Registry ID for image pulls."
  type        = string
}

variable "key_vault_id" {
  description = "Key Vault ID for CSI Secrets Store access."
  type        = string
}

variable "application_gateway_id" {
  description = "Existing Application Gateway ID for the managed AGIC add-on. Leave null to disable AGIC."
  type        = string
  default     = null
}

variable "cluster_admin_principal_ids" {
  description = "Entra group or service principal object IDs granted the AKS RBAC Cluster Admin role."
  type        = set(string)
  default     = []
}

variable "system_node_vm_size" {
  description = "VM size for the system node pool."
  type        = string
  default     = "Standard_B2s_v2"
}

variable "system_node_min_count" {
  description = "Minimum node count for the autoscaled system node pool."
  type        = number
  default     = 1
}

variable "system_node_max_count" {
  description = "Maximum node count for the autoscaled system node pool."
  type        = number
  default     = 2
}

variable "user_node_vm_size" {
  description = "VM size for the user node pool."
  type        = string
  default     = "Standard_B2s_v2"
}

variable "user_node_min_count" {
  description = "Minimum node count for the autoscaled user node pool."
  type        = number
  default     = 1
}

variable "user_node_max_count" {
  description = "Maximum node count for the autoscaled user node pool."
  type        = number
  default     = 3
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
