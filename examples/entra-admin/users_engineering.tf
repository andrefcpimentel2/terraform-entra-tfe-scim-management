# Engineering users. The map key must be unique across all users files.
locals {
  users_engineering = {
    "jane.doe" = {
      email      = "jane.doe@acme.com"
      first_name = "Jane"
      last_name  = "Doe"
      groups     = ["tfc-platform"]
    }
    "john.smith" = {
      email      = "john.smith@acme.com"
      first_name = "John"
      last_name  = "Smith"
      groups     = ["tfc-payments-dev"]
    }
    "li.wei" = {
      email      = "li.wei@acme.com"
      first_name = "Li"
      last_name  = "Wei"
      groups     = ["tfc-payments-dev", "tfc-readonly"]
    }
  }
}
