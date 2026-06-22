variable "assignments" {
  description = "Policy assignments keyed by assignment name."
  type = map(object({
    resource_id          = string
    policy_definition_id = string
    display_name         = string
    description          = optional(string, null)
    parameters           = optional(string, null)
    location             = optional(string, null)
    identity_type        = optional(string, null)
  }))
  default = {}
}
