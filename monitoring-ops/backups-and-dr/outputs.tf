output "backup_vault_arn" {
  description = "Backup vault ARN"
  value       = aws_backup_vault.main.arn
}

output "backup_plan_id" {
  description = "Backup plan ID"
  value       = aws_backup_plan.main.id
}

output "backup_role_arn" {
  description = "Backup IAM role ARN"
  value       = aws_iam_role.backup.arn
}

output "sns_topic_arn" {
  description = "SNS topic ARN for backup notifications"
  value       = aws_sns_topic.backup_notifications.arn
}

