output "user_object_ids" {
  description = "Map of user key to Entra object ID."
  value       = { for k, u in azuread_user.this : k => u.object_id }
}

output "group_object_ids" {
  description = "Map of group name to Entra object ID."
  value       = { for k, g in azuread_group.this : k => g.object_id }
}

output "initial_passwords" {
  description = "Initial passwords for new users. Users are forced to change them on first sign in."
  value       = { for k, p in random_password.this : k => p.result }
  sensitive   = true
}
