variable "organization" {
  description = "HCP Terraform organization that uses Entra ID for SSO and SCIM."
  type        = string
}

variable "enterprise_app_name" {
  description = "Display name of the HCP Terraform enterprise application in Entra ID."
  type        = string
  default     = "HCP Terraform"
}
