output "budget_name" {
  description = "Budget name"
  value       = aws_budgets_budget.monthly.name
}

output "sns_topic_arn" {
  description = "SNS topic ARN for cost alerts"
  value       = aws_sns_topic.cost_alerts.arn
}

output "anomaly_monitor_arn" {
  description = "Cost anomaly monitor ARN"
  value       = var.enable_anomaly_detection ? aws_ce_anomaly_monitor.main[0].arn : null
}

