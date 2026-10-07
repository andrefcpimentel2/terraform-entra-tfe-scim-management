variable "organization" {
  description = "HCP Terraform organization name."
  type        = string
}

variable "projects" {
  description = "Projects to manage. The map key is the project name."
  type = map(object({
    description = optional(string)
    tags        = optional(map(string))
  }))
  default = {}
}

variable "teams" {
  description = <<-EOT
    Teams to manage. The map key is the team name and must match the IdP group name
    so SCIM links the group to this team.
    organization_access is a list of organization permissions to enable, for example ["read_workspaces", "read_projects"].
    projects maps a project name to an access level: read, write, maintain or admin.
  EOT
  type = map(object({
    visibility          = optional(string, "organization")
    organization_access = optional(list(string), [])
    projects            = optional(map(string), {})
  }))
  default = {}

  validation {
    condition     = alltrue([for k in keys(var.teams) : !contains(["owners", "sso"], lower(k))])
    error_message = "The owners and sso team names are reserved."
  }

  validation {
    condition     = alltrue([for t in var.teams : contains(["organization", "secret"], t.visibility)])
    error_message = "visibility must be organization or secret."
  }

  validation {
    condition = alltrue(flatten([
      for t in var.teams : [
        for p in t.organization_access : contains([
          "read_workspaces", "read_projects", "manage_workspaces", "manage_projects",
          "manage_policies", "manage_policy_overrides", "delegate_policy_overrides",
          "manage_run_tasks", "manage_vcs_settings", "manage_providers", "manage_modules",
          "manage_agent_pools", "manage_membership", "manage_teams",
          "manage_organization_access", "access_secret_teams",
        ], p)
      ]
    ]))
    error_message = "organization_access contains an unknown permission."
  }

  validation {
    condition = alltrue(flatten([
      for t in var.teams : [for a in values(t.projects) : contains(["read", "write", "maintain", "admin"], a)]
    ]))
    error_message = "Project access must be read, write, maintain or admin."
  }

  validation {
    condition = alltrue(flatten([
      for t in var.teams : [for p in keys(t.projects) : contains(keys(var.projects), p)]
    ]))
    error_message = "Every project listed on a team must also exist in var.projects."
  }
}
