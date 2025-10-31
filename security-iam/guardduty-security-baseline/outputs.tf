output "guardduty_detector_id" {
  description = "GuardDuty detector ID"
  value       = var.enable_guardduty ? aws_guardduty_detector.main.id : null
}

output "security_hub_arn" {
  description = "Security Hub ARN"
  value       = var.enable_security_hub ? aws_securityhub_account.main[0].arn : null
}

output "config_recorder_id" {
  description = "AWS Config recorder ID"
  value       = var.enable_config ? aws_config_configuration_recorder.main[0].id : null
}

output "sns_topic_arn" {
  description = "SNS topic ARN for security alerts"
  value       = var.create_sns_topic ? aws_sns_topic.security_alerts[0].arn : null
}

