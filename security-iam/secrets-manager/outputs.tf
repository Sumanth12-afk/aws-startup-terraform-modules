output "secret_arn" {
  description = "ARN of the secret"
  value       = aws_secretsmanager_secret.main.arn
}

output "secret_id" {
  description = "ID of the secret"
  value       = aws_secretsmanager_secret.main.id
}

output "secret_name" {
  description = "Name of the secret"
  value       = aws_secretsmanager_secret.main.name
}

output "version_id" {
  description = "Version ID of the secret"
  value       = length(aws_secretsmanager_secret_version.main) > 0 ? aws_secretsmanager_secret_version.main[0].version_id : null
}

