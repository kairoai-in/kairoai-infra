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

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
