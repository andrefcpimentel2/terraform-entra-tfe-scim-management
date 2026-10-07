output "user_ids" {
  description = "Map of user key to Okta user ID."
  value       = { for k, u in okta_user.this : k => u.id }
}

output "group_ids" {
  description = "Map of group name to Okta group ID."
  value       = { for k, g in okta_group.this : k => g.id }
}
