# Finance users. The map key must be unique across all users files.
locals {
  users_finance = {
    "ana.lopez" = {
      email      = "ana.lopez@acme.com"
      first_name = "Ana"
      last_name  = "Lopez"
      groups     = ["tfc-finance-dev"]
    }
    "marc.dubois" = {
      email      = "marc.dubois@acme.com"
      first_name = "Marc"
      last_name  = "Dubois"
      groups     = ["tfc-readonly"]
      enabled    = false
    }
  }
}
