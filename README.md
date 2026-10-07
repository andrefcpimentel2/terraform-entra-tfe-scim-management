# HCP Terraform SCIM user management

Two provider modules that manage users, groups and app assignments on the IdP side. SCIM then provisions them into HCP Terraform.
One tfe module to manage HCP Terraform / Terraform Enterprise team permissions

| Module | IdP | Manages |
|---|---|---|
| `modules/entra-scim` | Microsoft Entra ID | users, security groups, membership, enterprise app assignment |
| `modules/okta-scim` | Okta | users, groups, membership, app assignment |
| `modules/tfe-teams` | HCP Terraform | teams, projects, organization access, team project access |



## Admin workflow for Entra (examples/entra-admin)

One workspace, one pull request, one apply. Teams, permissions, groups and users are all plain `.tf` files.

```
examples/entra-admin/
  main.tf               providers, tfe-teams then entra-scim
  teams.tf              teams and project access (team name = Entra group name)
  users.tf              merges every users_<bu>.tf file into one map
  users_engineering.tf  one file per business unit
  users_finance.tf
```

* Add a user: add an entry to the right `users_<bu>.tf`.
* Remove a user: delete the entry.
* Change access: edit the user's `groups` list, or the team's permissions in `teams.tf`.
* New business unit: create `users_<bu>.tf` and add it to `user_files` in `users.tf`.

The plan fails if the same user key appears in two files.

At thousands of users:

* Each user is two resources (user and initial password), so plans refresh thousands of objects and take several minutes.
* Set `TFE_PARALLELISM` (for example 5) as a workspace environment variable if Microsoft Graph starts throttling.
* Onboard large batches in a few pull requests rather than one.

## How the pieces fit

1. `tfe-teams` creates the teams and their permissions in HCP Terraform.
2. The IdP module creates groups with the same names and assigns them to the app.
3. SCIM pushes the groups. HCP Terraform links each group to the existing team with the same name and syncs members.

Team names in `tfe-teams` must match the IdP group names exactly (case is synced from the IdP). Membership is only managed by SCIM, never by `tfe-teams`.

Apply `tfe-teams` first. If SCIM already created a team, import it before applying:

```hcl
import {
  to = module.teams["acme-entra"].tfe_team.this["tfc-platform"]
  id = "acme-entra/tfc-platform"
}
```

If a group is deleted in the IdP, SCIM deletes the team and its permissions. Remove it from `tfe-teams` in the same change, or the next apply recreates an empty team.

## Usage

Edit `terraform.tfvars` and run `terraform apply`.

* Add a user: add an entry to `users`.
* Remove a user: delete the entry. The user is deleted in the IdP and SCIM deprovisions it.
* Edit a user: change attributes or the `groups` list.
* Disable without deleting: `enabled = false` (Entra) or `status = "SUSPENDED"` (Okta).

Groups are assigned to the app by default (`assign_to_app = true`), so any member of a managed group is in SCIM scope. Set `assign_to_app = true` on a user only if they need access without a group.

Group membership is authoritative. A managed group contains exactly the users that list it.

## Notes

### Entra

* The enterprise app must use "Sync only assigned users and groups".
* Assigning groups to an app needs Entra ID P1 or P2. Nested groups are not provisioned.
* `user_principal_name` defaults to `email`, so the domain must be verified in the tenant.
* New users get a random initial password: `terraform output -json initial_passwords`.
* Entra provisions on a ~40 minute cycle. Use "Provision on demand" to test.

### Okta

* Assigning a group to the app provisions its members. Pushing the group itself (to link it to an HCP Terraform team) is not available in the Okta provider. Create one Push Groups rule in the app, for example "name starts with `tfc-`", and every group this module creates is pushed automatically.
* Removing a user from `users` deactivates and deletes it in Okta.

### HCP Terraform

* `examples/tfe` manages both orgs in one apply. The token must be able to manage both orgs (an owner user token), otherwise run one workspace per org.
* `organization_access` is a list of permissions to turn on. Anything not listed is off.
* Project access uses the fixed levels `read`, `write`, `maintain` and `admin`.
* `owners` and `sso` are reserved team names.

## Tests

Each module has plan tests that use mock providers, so no credentials are needed:

```
cd modules/tfe-teams && terraform init && terraform test
```
