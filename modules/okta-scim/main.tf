locals {
  app_users  = { for k, u in var.users : k => u if u.assign_to_app }
  app_groups = { for k, g in var.groups : k => g if g.assign_to_app }

  # Group name to list of user keys. Empty groups are left out because
  # okta_group_memberships needs at least one user.
  group_members = {
    for gk, g in var.groups : gk => [for uk, u in var.users : uk if contains(u.groups, gk)]
  }
  groups_with_members = { for gk, members in local.group_members : gk => members if length(members) > 0 }
}

resource "okta_user" "this" {
  for_each = var.users

  login        = coalesce(each.value.login, each.value.email)
  email        = each.value.email
  first_name   = each.value.first_name
  last_name    = each.value.last_name
  display_name = each.value.display_name
  status       = each.value.status
}

resource "okta_group" "this" {
  for_each = var.groups

  name        = each.key
  description = each.value.description
}

# Membership is authoritative: the group contains exactly the users that list it.
resource "okta_group_memberships" "this" {
  for_each = local.groups_with_members

  group_id        = okta_group.this[each.key].id
  users           = [for uk in each.value : okta_user.this[uk].id]
  track_all_users = true
}

# Assigning a group to the app puts its members in SCIM scope.
# Pushing the group itself to HCP Terraform is handled by a Push Groups rule in Okta.
resource "okta_app_group_assignment" "this" {
  for_each = local.app_groups

  app_id   = var.app_id
  group_id = okta_group.this[each.key].id
}

# Optional direct assignment for users that should be provisioned without a group.
resource "okta_app_user" "this" {
  for_each = local.app_users

  app_id   = var.app_id
  user_id  = okta_user.this[each.key].id
  username = okta_user.this[each.key].login
}
