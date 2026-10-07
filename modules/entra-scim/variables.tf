variable "service_principal_object_id" {
  description = "Object ID of the HCP Terraform enterprise application (service principal) that has SCIM provisioning enabled."
  type        = string
}

variable "app_role_id" {
  description = "App role used when assigning users and groups to the enterprise application. The default is the built in Default Access role."
  type        = string
  default     = "00000000-0000-0000-0000-000000000000"
}

variable "groups" {
  description = "Groups to manage. The map key is the group display name."
  type = map(object({
    description   = optional(string)
    assign_to_app = optional(bool, true)
  }))
  default = {}
}

variable "users" {
  description = "Users to manage. The map key is used as the mail nickname."
  type = map(object({
    email               = string
    first_name          = string
    last_name           = string
    display_name        = optional(string)
    user_principal_name = optional(string)
    groups              = optional(list(string), [])
    enabled             = optional(bool, true)
    assign_to_app       = optional(bool, false)
  }))
  default = {}

  validation {
    condition = alltrue(flatten([
      for u in var.users : [for g in u.groups : contains(keys(var.groups), g)]
    ]))
    error_message = "Every group listed on a user must also exist in var.groups."
  }
}
