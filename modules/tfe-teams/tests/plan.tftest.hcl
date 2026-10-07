mock_provider "tfe" {}

variables {
  organization = "acme"
  projects = {
    "platform" = { description = "Platform" }
    "apps"     = {}
  }
  teams = {
    "tfc-platform" = {
      organization_access = ["read_workspaces", "read_projects"]
      projects            = { "platform" = "admin", "apps" = "maintain" }
    }
    "tfc-developers" = {
      projects = { "apps" = "write" }
    }
  }
}

run "valid" {
  command = plan
  assert {
    condition     = length(tfe_team_project_access.this) == 3
    error_message = "expected 3 project access entries"
  }
  assert {
    condition     = tfe_team.this["tfc-platform"].organization_access[0].read_projects == true && tfe_team.this["tfc-platform"].organization_access[0].manage_teams == false
    error_message = "organization_access mapping is wrong"
  }
}

run "unknown_project" {
  command = plan
  variables {
    teams = { "x-team" = { projects = { "nope" = "read" } } }
  }
  expect_failures = [var.teams]
}

run "bad_permission" {
  command = plan
  variables {
    teams = { "x-team" = { organization_access = ["manage_everything"] } }
  }
  expect_failures = [var.teams]
}

run "reserved_name" {
  command = plan
  variables {
    teams = { "owners" = {} }
  }
  expect_failures = [var.teams]
}

run "empty" {
  command = plan
  variables {
    projects = {}
    teams    = {}
  }
}
