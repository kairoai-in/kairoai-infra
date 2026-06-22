variable "name" {
  description = "Service Bus namespace name."
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

variable "sku" {
  description = "Service Bus SKU."
  type        = string
  default     = "Standard"
}

variable "capacity" {
  description = "Messaging unit capacity for Premium Service Bus namespaces. Ignored for Standard."
  type        = number
  default     = 1
}

variable "premium_messaging_partitions" {
  description = "Premium messaging partitions for Premium Service Bus namespaces."
  type        = number
  default     = 1
}

variable "queues" {
  description = "Queue names to create."
  type        = set(string)
  default     = []
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
