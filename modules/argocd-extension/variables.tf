variable "name" {
  description = "AKS extension name."
  type        = string
  default     = "argocd"
}

variable "cluster_id" {
  description = "AKS cluster resource ID."
  type        = string
}

variable "namespace" {
  description = "Namespace where the Argo CD extension is installed."
  type        = string
  default     = "argocd"
}

variable "public_url" {
  description = "Public URL used by Argo CD for redirects and callbacks."
  type        = string
}

variable "redis_ha_enabled" {
  description = "Enable Redis HA. Keep disabled for small test clusters."
  type        = bool
  default     = false
}

variable "application_namespaces" {
  description = "Namespaces where Argo CD can manage application resources."
  type        = list(string)
  default     = ["argocd", "kairoai"]
}

variable "default_rbac_policy" {
  description = "Default Argo CD RBAC role."
  type        = string
  default     = "role:readonly"
}

variable "extra_configuration_settings" {
  description = "Additional Microsoft.ArgoCD extension Helm configuration settings."
  type        = map(string)
  default     = {}
}
