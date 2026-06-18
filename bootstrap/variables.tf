variable "location" {
  description = "Azure region for Terraform state resources."
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Resource group for Terraform state resources."
  type        = string
}

variable "storage_account_name" {
  description = "Globally unique Azure Storage Account name for Terraform state."
  type        = string
}

variable "container_name" {
  description = "Blob container name for Terraform state."
  type        = string
  default     = "tfstate"
}
