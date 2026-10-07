locals {
  app_users  = { for k, u in var.users : k => u if u.assign_to_app }
  app_groups = { for k, g in var.groups : k => g if g.assign_to_app }
}

# Initial password for new users. They must change it on first sign in.
resource "random_password" "this" {
  for_each = var.users

  length      = 20
  special     = true
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
  min_special = 1
}

resource "azuread_user" "this" {
  for_each = var.users

  user_principal_name   = coalesce(each.value.user_principal_name, each.value.email)
  display_name          = coalesce(each.value.display_name, "${each.value.first_name} ${each.value.last_name}")
  given_name            = each.value.first_name
  surname               = each.value.last_name
  mail                  = each.value.email
  mail_nickname         = each.key
  account_enabled       = each.value.enabled
  password              = random_password.this[each.key].result
  force_password_change = true

  lifecycle {
    ignore_changes = [password, force_password_change]
  }
}

# Membership is authoritative: the group contains exactly the users that list it.
resource "azuread_group" "this" {
  for_each = var.groups

  display_name            = each.key
  description             = each.value.description
  security_enabled        = true
  prevent_duplicate_names = true

  members = [
    for uk, u in var.users : azuread_user.this[uk].object_id if contains(u.groups, each.key)
  ]
}

# Assigning a group to the enterprise app puts its members in SCIM scope.
# Group assignment requires Entra ID P1 or P2. Nested groups are not supported.
resource "azuread_app_role_assignment" "group" {
  for_each = local.app_groups

  app_role_id         = var.app_role_id
  principal_object_id = azuread_group.this[each.key].object_id
  resource_object_id  = var.service_principal_object_id
}

# Optional direct assignment for users that should be provisioned without a group.
resource "azuread_app_role_assignment" "user" {
  for_each = local.app_users

  app_role_id         = var.app_role_id
  principal_object_id = azuread_user.this[each.key].object_id
  resource_object_id  = var.service_principal_object_id
}
