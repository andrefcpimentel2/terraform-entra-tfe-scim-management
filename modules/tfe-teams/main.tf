locals {
  # One entry per team and project pair, keyed as "team/project".
  project_access = merge([
    for tk, t in var.teams : {
      for pk, access in t.projects : "${tk}/${pk}" => {
        team    = tk
        project = pk
        access  = access
      }
    }
  ]...)
}

resource "tfe_project" "this" {
  for_each = var.projects

  organization = var.organization
  name         = each.key
  description  = each.value.description
  tags         = each.value.tags
}

# Membership is not managed here. SCIM links the IdP group with the same name
# to this team and keeps its members in sync.
resource "tfe_team" "this" {
  for_each = var.teams

  organization = var.organization
  name         = each.key
  visibility   = each.value.visibility

  organization_access {
    read_workspaces            = contains(each.value.organization_access, "read_workspaces")
    read_projects              = contains(each.value.organization_access, "read_projects")
    manage_workspaces          = contains(each.value.organization_access, "manage_workspaces")
    manage_projects            = contains(each.value.organization_access, "manage_projects")
    manage_policies            = contains(each.value.organization_access, "manage_policies")
    manage_policy_overrides    = contains(each.value.organization_access, "manage_policy_overrides")
    delegate_policy_overrides  = contains(each.value.organization_access, "delegate_policy_overrides")
    manage_run_tasks           = contains(each.value.organization_access, "manage_run_tasks")
    manage_vcs_settings        = contains(each.value.organization_access, "manage_vcs_settings")
    manage_providers           = contains(each.value.organization_access, "manage_providers")
    manage_modules             = contains(each.value.organization_access, "manage_modules")
    manage_agent_pools         = contains(each.value.organization_access, "manage_agent_pools")
    manage_membership          = contains(each.value.organization_access, "manage_membership")
    manage_teams               = contains(each.value.organization_access, "manage_teams")
    manage_organization_access = contains(each.value.organization_access, "manage_organization_access")
    access_secret_teams        = contains(each.value.organization_access, "access_secret_teams")
  }
}

resource "tfe_team_project_access" "this" {
  for_each = local.project_access

  team_id    = tfe_team.this[each.value.team].id
  project_id = tfe_project.this[each.value.project].id
  access     = each.value.access
}
