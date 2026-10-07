terraform {
  required_version = ">= 1.9"

  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = ">= 0.60"
    }
  }
}

# Auth via TFE_TOKEN. Organization tokens only work for one org, so use a
# token from a user who is an owner in both orgs, or split this into one
# workspace per org.
provider "tfe" {}

variable "orgs" {
  description = "One entry per HCP Terraform organization."
  type = map(object({
    projects = optional(map(object({
      description = optional(string)
      tags        = optional(map(string))
    })), {})
    teams = optional(map(object({
      visibility          = optional(string, "organization")
      organization_access = optional(list(string), [])
      projects            = optional(map(string), {})
    })), {})
  }))
  default = {}
}

module "teams" {
  source   = "../../modules/tfe-teams"
  for_each = var.orgs

  organization = each.key
  projects     = each.value.projects
  teams        = each.value.teams
}

output "team_ids" {
  value = { for org, m in module.teams : org => m.team_ids }
}
