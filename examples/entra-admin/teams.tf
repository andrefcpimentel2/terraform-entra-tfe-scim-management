# Each team name is also the Entra group name.
locals {
  projects = {
    "platform" = { description = "Shared platform infrastructure" }
    "payments" = { description = "Payments services" }
    "finance"  = { description = "Finance reporting" }
  }

  teams = {
    "tfc-platform" = {
      organization_access = ["read_workspaces", "read_projects", "manage_modules"]
      projects = {
        "platform" = "admin"
        "payments" = "maintain"
      }
    }
    "tfc-payments-dev" = {
      projects = { "payments" = "write" }
    }
    "tfc-finance-dev" = {
      projects = { "finance" = "write" }
    }
    "tfc-readonly" = {
      organization_access = ["read_workspaces", "read_projects"]
    }
  }
}
