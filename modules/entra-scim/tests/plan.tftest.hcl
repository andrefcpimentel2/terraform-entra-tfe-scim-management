mock_provider "azuread" {}
mock_provider "random" {}

variables {
  service_principal_object_id = "00000000-0000-0000-0000-000000000001"
  groups = {
    "tfc-a" = {}
    "tfc-b" = { assign_to_app = false }
  }
  users = {
    "u1" = { email = "u1@x.com", first_name = "U", last_name = "One", groups = ["tfc-a", "tfc-b"] }
    "u2" = { email = "u2@x.com", first_name = "U", last_name = "Two", enabled = false, assign_to_app = true }
  }
}

run "valid" {
  command = plan
  assert {
    condition     = length(azuread_app_role_assignment.group) == 1 && length(azuread_app_role_assignment.user) == 1
    error_message = "unexpected assignment counts"
  }
  assert {
    condition     = azuread_user.this["u1"].display_name == "U One" && azuread_user.this["u1"].user_principal_name == "u1@x.com"
    error_message = "defaults not applied"
  }
}

run "unknown_group" {
  command = plan
  variables {
    users = { "u1" = { email = "a@x.com", first_name = "a", last_name = "b", groups = ["nope"] } }
  }
  expect_failures = [var.users]
}
