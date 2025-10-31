# Table Outputs
output "table_id" {
  description = "The name of the table"
  value       = aws_dynamodb_table.main.id
}

output "table_arn" {
  description = "The ARN of the table"
  value       = aws_dynamodb_table.main.arn
}

output "table_name" {
  description = "The name of the table"
  value       = aws_dynamodb_table.main.name
}

output "table_stream_arn" {
  description = "The ARN of the Table Stream (if enabled)"
  value       = var.enable_streams ? aws_dynamodb_table.main.stream_arn : null
}

output "table_stream_label" {
  description = "The timestamp of the stream"
  value       = var.enable_streams ? aws_dynamodb_table.main.stream_label : null
}

# Hash and Range Keys
output "hash_key" {
  description = "The partition key"
  value       = aws_dynamodb_table.main.hash_key
}

output "range_key" {
  description = "The sort key"
  value       = var.range_key
}

# CloudWatch Alarm ARNs
output "cloudwatch_alarm_arns" {
  description = "ARNs of CloudWatch alarms"
  value = {
    read_throttle  = aws_cloudwatch_metric_alarm.read_throttle.arn
    write_throttle = aws_cloudwatch_metric_alarm.write_throttle.arn
    user_errors    = aws_cloudwatch_metric_alarm.user_errors.arn
    system_errors  = aws_cloudwatch_metric_alarm.system_errors.arn
  }
}

# Configuration Outputs
output "billing_mode" {
  description = "The billing mode of the table"
  value       = var.billing_mode
}

output "point_in_time_recovery_enabled" {
  description = "Whether point-in-time recovery is enabled"
  value       = var.enable_point_in_time_recovery
}

output "encryption_enabled" {
  description = "Whether server-side encryption is enabled"
  value       = var.enable_encryption
}

output "ttl_enabled" {
  description = "Whether TTL is enabled"
  value       = var.enable_ttl
}

# Auto Scaling Outputs
output "autoscaling_enabled" {
  description = "Whether auto-scaling is enabled"
  value       = var.enable_autoscaling
}

output "autoscaling_read_target_arn" {
  description = "ARN of the read capacity auto-scaling target"
  value       = var.billing_mode == "PROVISIONED" && var.enable_autoscaling ? aws_appautoscaling_target.read[0].arn : null
}

output "autoscaling_write_target_arn" {
  description = "ARN of the write capacity auto-scaling target"
  value       = var.billing_mode == "PROVISIONED" && var.enable_autoscaling ? aws_appautoscaling_target.write[0].arn : null
}

