# All users in one map. Add one line here for every new users_<bu>.tf file.
locals {
  user_files = [
    local.users_engineering,
    local.users_finance,
  ]

  users = merge(local.user_files...)
}

# merge() keeps only the last entry when a key appears in two files,
# so fail the plan instead of silently dropping a user.
output "user_count" {
  value = length(local.users)

  precondition {
    condition     = length(local.users) == length(flatten([for f in local.user_files : keys(f)]))
    error_message = "The same user key appears in more than one users_*.tf file."
  }
}
