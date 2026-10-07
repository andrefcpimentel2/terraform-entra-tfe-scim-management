terraform {
  required_version = ">= 1.9"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.0"
    }
  }
}

# Auth via ARM_TENANT_ID, ARM_CLIENT_ID and ARM_CLIENT_SECRET (or OIDC dynamic credentials).
# The identity needs User.ReadWrite.All, Group.ReadWrite.All and AppRoleAssignment.ReadWrite.All.
provider "azuread" {}

variable "enterprise_app_name" {
  type    = string
  default = "HCP Terraform"
}

variable "groups" {
  type    = any
  default = {}
}

variable "users" {
  type    = any
  default = {}
}

data "azuread_service_principal" "hcp_terraform" {
  display_name = var.enterprise_app_name
}

module "scim" {
  source = "../../modules/entra-scim"

  service_principal_object_id = data.azuread_service_principal.hcp_terraform.object_id
  groups                      = var.groups
  users                       = var.users
}

output "initial_passwords" {
  value     = module.scim.initial_passwords
  sensitive = true
}
