mock_provider "okta" {}

variables {
  app_id = "0oa123"
  groups = {
    "tfc-a"     = {}
    "tfc-b"     = {}
    "tfc-empty" = { assign_to_app = false }
  }
  users = {
    "u1" = { email = "u1@x.com", first_name = "U", last_name = "One", groups = ["tfc-a", "tfc-b"] }
    "u2" = { email = "u2@x.com", first_name = "U", last_name = "Two", groups = ["tfc-a"], assign_to_app = true }
  }
}

run "valid" {
  command = plan
  assert {
    condition     = length(okta_group_memberships.this) == 2 && length(okta_app_group_assignment.this) == 2 && length(okta_app_user.this) == 1
    error_message = "unexpected resource counts"
  }
  assert {
    condition     = okta_user.this["u1"].login == "u1@x.com"
    error_message = "login should default to email"
  }
}

run "unknown_group" {
  command = plan
  variables {
    users = { "u1" = { email = "a@x.com", first_name = "a", last_name = "b", groups = ["nope"] } }
  }
  expect_failures = [var.users]
}

run "bad_status" {
  command = plan
  variables {
    users = { "u1" = { email = "a@x.com", first_name = "a", last_name = "b", status = "GONE" } }
  }
  expect_failures = [var.users]
}
