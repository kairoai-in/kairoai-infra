variable "name" {
  description = "Application Gateway name."
  type        = string
}

variable "public_ip_name" {
  description = "Public IP name for the Application Gateway frontend."
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

variable "subnet_id" {
  description = "Subnet ID dedicated to Application Gateway."
  type        = string
}

variable "backend_fqdns" {
  description = "Backend FQDNs. For AGIC this can stay empty and Kubernetes ingress owns backend pools."
  type        = list(string)
  default     = []
}

variable "frontend_port" {
  description = "Frontend listener port."
  type        = number
  default     = 80
}

variable "backend_port" {
  description = "Backend HTTP settings port."
  type        = number
  default     = 80
}

variable "min_capacity" {
  description = "Minimum autoscale capacity."
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum autoscale capacity."
  type        = number
  default     = 2
}

variable "waf_mode" {
  description = "WAF mode."
  type        = string
  default     = "Prevention"
}

variable "waf_policy_name" {
  description = "Application Gateway WAF policy name. Defaults to policy-<gateway-name>."
  type        = string
  default     = null
}

variable "log_analytics_workspace_id" {
  description = "Optional Log Analytics workspace ID for Application Gateway diagnostics."
  type        = string
  default     = null
}

variable "diagnostic_log_categories" {
  description = "Application Gateway diagnostic log categories to send to Log Analytics."
  type        = set(string)
  default = [
    "ApplicationGatewayAccessLog",
    "ApplicationGatewayPerformanceLog",
    "ApplicationGatewayFirewallLog",
  ]
}

variable "action_group_id" {
  description = "Optional Azure Monitor action group ID for Application Gateway alerts."
  type        = string
  default     = null
}

variable "unhealthy_host_threshold" {
  description = "Unhealthy backend host count threshold for Application Gateway alerting."
  type        = number
  default     = 0
}

variable "failed_requests_threshold" {
  description = "Failed request count threshold for Application Gateway alerting."
  type        = number
  default     = 25
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
