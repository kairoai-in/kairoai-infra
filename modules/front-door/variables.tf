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

variable "dns_zone_id" {
  description = "Azure DNS zone ID for validating Front Door managed custom domains."
  type        = string
}

variable "routes" {
  description = "Front Door routes keyed by logical route name."
  type = map(object({
    host_name              = string
    origin_host_name       = string
    origin_host_header     = string
    patterns_to_match      = optional(list(string), ["/*"])
    health_probe_path      = optional(string, "/health")
    forwarding_protocol    = optional(string, "HttpOnly")
    link_to_default_domain = optional(bool, false)
  }))
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

variable "metric_alerts_enabled" {
  description = "Create Front Door metric alerts. Set true only when action_group_id is provided."
  type        = bool
  default     = false
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
