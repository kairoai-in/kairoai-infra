variable "location" {
  description = "Azure region for Terraform state resources."
  type        = string
  default     = "centralindia"
}

variable "subscription_id" {
  description = "Hub subscription ID where Terraform state resources are created."
  type        = string
  default     = "5b942f88-17e6-4026-ae23-d520365fb916"
}

variable "tenant_id" {
  description = "Azure tenant ID."
  type        = string
  default     = "83474cb5-f1fa-4d06-906c-e5dad12ce3b9"
}

variable "resource_group_name" {
  description = "Resource group for Terraform state resources."
  type        = string
}

variable "storage_account_name" {
  description = "Globally unique Azure Storage Account name for Terraform state."
  type        = string
}

variable "container_names" {
  description = "Blob container names for Terraform state."
  type        = list(string)
  default     = ["hubtfstate", "testtfstate", "prodtfstate"]
}

variable "account_replication_type" {
  description = "Replication type for the Terraform state storage account."
  type        = string
  default     = "ZRS"
}

variable "public_network_access_enabled" {
  description = "Allow public network access during bootstrap. Disable after private endpoint access is established."
  type        = bool
  default     = true
}

variable "blob_delete_retention_days" {
  description = "Blob soft delete retention in days."
  type        = number
  default     = 30
}

variable "container_delete_retention_days" {
  description = "Container soft delete retention in days."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Additional tags for Terraform state resources."
  type        = map(string)
  default     = {}
}

variable "state_blob_data_contributor_object_ids" {
  description = "Additional Entra object IDs granted Storage Blob Data Contributor on the Terraform state storage account."
  type        = list(string)
  default     = []
}
