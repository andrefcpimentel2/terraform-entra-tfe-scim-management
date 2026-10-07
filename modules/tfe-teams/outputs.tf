output "team_ids" {
  description = "Map of team name to team ID."
  value       = { for k, t in tfe_team.this : k => t.id }
}

output "project_ids" {
  description = "Map of project name to project ID."
  value       = { for k, p in tfe_project.this : k => p.id }
}
