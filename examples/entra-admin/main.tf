terraform {
  required_version = ">= 1.9"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = ">= 0.60"
    }
  }
}

# Entra auth: dynamic credentials (OIDC) from the HCP Terraform workspace.
# The identity needs User.ReadWrite.All, Group.ReadWrite.All and AppRoleAssignment.ReadWrite.All.
provider "azuread" {}

# HCP Terraform auth: TFE_TOKEN set as a sensitive workspace variable.
provider "tfe" {}

data "azuread_service_principal" "hcp_terraform" {
  display_name = var.enterprise_app_name
}

# Teams first, so SCIM links each Entra group to a team that already has its permissions.
module "teams" {
  source = "../../modules/tfe-teams"

  organization = var.organization
  projects     = local.projects
  teams        = local.teams
}

# One Entra group per team, with the same name.
module "entra" {
  source = "../../modules/entra-scim"

  service_principal_object_id = data.azuread_service_principal.hcp_terraform.object_id
  groups                      = { for name in keys(local.teams) : name => {} }
  users                       = local.users

  depends_on = [module.teams]
}
