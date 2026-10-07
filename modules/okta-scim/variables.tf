variable "app_id" {
  description = "ID of the HCP Terraform app in Okta that has SCIM provisioning enabled."
  type        = string
}

variable "groups" {
  description = "Groups to manage. The map key is the group name."
  type = map(object({
    description   = optional(string)
    assign_to_app = optional(bool, true)
  }))
  default = {}
}

variable "users" {
  description = "Users to manage. The map key is only used as a stable identifier in state."
  type = map(object({
    email         = string
    first_name    = string
    last_name     = string
    login         = optional(string)
    display_name  = optional(string)
    groups        = optional(list(string), [])
    status        = optional(string, "ACTIVE")
    assign_to_app = optional(bool, false)
  }))
  default = {}

  validation {
    condition = alltrue(flatten([
      for u in var.users : [for g in u.groups : contains(keys(var.groups), g)]
    ]))
    error_message = "Every group listed on a user must also exist in var.groups."
  }

  validation {
    condition     = alltrue([for u in var.users : contains(["ACTIVE", "SUSPENDED", "DEPROVISIONED", "STAGED"], u.status)])
    error_message = "status must be one of ACTIVE, SUSPENDED, DEPROVISIONED or STAGED."
  }
}
