variable "workload" {
  description = "Short workload name used in Azure resource names."
  type        = string
}

variable "environment" {
  description = "Environment code, for example hub, test, prod, or prod-dr."
  type        = string
}

variable "region_code" {
  description = "Short Azure region code, for example ci or si."
  type        = string
}

variable "suffix" {
  description = "Optional unique suffix for globally unique resources."
  type        = string
  default     = ""
}

variable "public_domain" {
  description = "Primary public DNS domain for the workload."
  type        = string
  default     = "kairoai.in"
}
