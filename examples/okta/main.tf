terraform {
  required_version = ">= 1.9"

  required_providers {
    okta = {
      source  = "okta/okta"
      version = ">= 4.0"
    }
  }
}

# Auth via OKTA_ORG_NAME, OKTA_BASE_URL and OKTA_API_TOKEN (or OAuth private key).
provider "okta" {}

variable "app_label" {
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

data "okta_app" "hcp_terraform" {
  label = var.app_label
}

module "scim" {
  source = "../../modules/okta-scim"

  app_id = data.okta_app.hcp_terraform.id
  groups = var.groups
  users  = var.users
}
