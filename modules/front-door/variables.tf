variable "profile_name" {
  description = "Azure Front Door profile name."
  type        = string
}

variable "endpoint_name" {
  description = "Azure Front Door endpoint name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "sku_name" {
  description = "Front Door SKU."
  type        = string
  default     = "Premium_AzureFrontDoor"
}

variable "origin_host_name" {
  description = "Origin host name, normally Application Gateway public IP DNS or frontend host."
  type        = string
}

variable "origin_host_header" {
  description = "Host header sent to the origin."
  type        = string
}

variable "patterns_to_match" {
  description = "Route path patterns."
  type        = list(string)
  default     = ["/*"]
}

variable "log_analytics_workspace_id" {
  description = "Optional Log Analytics workspace ID for Front Door diagnostics."
  type        = string
  default     = null
}

variable "diagnostic_log_categories" {
  description = "Front Door diagnostic log categories to send to Log Analytics."
  type        = set(string)
  default = [
    "FrontDoorAccessLog",
    "FrontDoorHealthProbeLog",
  ]
}

variable "action_group_id" {
  description = "Optional Azure Monitor action group ID for Front Door alerts."
  type        = string
  default     = null
}

variable "origin_health_threshold" {
  description = "Minimum acceptable Front Door origin health percentage."
  type        = number
  default     = 90
}

variable "latency_threshold_ms" {
  description = "Front Door total latency threshold in milliseconds."
  type        = number
  default     = 2000
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
