# Application Load Balancer Module - Outputs

# ALB Outputs
output "alb_id" {
  description = "ID of the Application Load Balancer"
  value       = aws_lb.main.id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_arn_suffix" {
  description = "ARN suffix of the Application Load Balancer (for CloudWatch metrics)"
  value       = aws_lb.main.arn_suffix
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Canonical hosted zone ID of the load balancer"
  value       = aws_lb.main.zone_id
}

# Security Group Outputs
output "security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "security_group_arn" {
  description = "ARN of the ALB security group"
  value       = aws_security_group.alb.arn
}

# Target Group Outputs
output "target_group_arns" {
  description = "Map of target group names to ARNs"
  value       = { for k, v in aws_lb_target_group.main : k => v.arn }
}

output "target_group_arn_suffixes" {
  description = "Map of target group names to ARN suffixes (for CloudWatch metrics)"
  value       = { for k, v in aws_lb_target_group.main : k => v.arn_suffix }
}

output "target_group_names" {
  description = "Map of target group keys to names"
  value       = { for k, v in aws_lb_target_group.main : k => v.name }
}

output "default_target_group_arn" {
  description = "ARN of the default target group"
  value       = aws_lb_target_group.main[var.default_target_group].arn
}

# Listener Outputs
output "http_listener_arn" {
  description = "ARN of the HTTP listener"
  value       = var.enable_http ? aws_lb_listener.http[0].arn : null
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener"
  value       = var.enable_https ? aws_lb_listener.https[0].arn : null
}

# CloudWatch Alarm Outputs
output "response_time_alarm_arn" {
  description = "ARN of the response time CloudWatch alarm"
  value       = var.enable_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.target_response_time[0].arn : null
}

output "unhealthy_hosts_alarm_arn" {
  description = "ARN of the unhealthy hosts CloudWatch alarm"
  value       = var.enable_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.unhealthy_hosts[0].arn : null
}

output "elb_5xx_alarm_arn" {
  description = "ARN of the ELB 5XX errors CloudWatch alarm"
  value       = var.enable_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.elb_5xx_errors[0].arn : null
}

# Metadata Outputs
output "alb_name" {
  description = "Name of the Application Load Balancer"
  value       = aws_lb.main.name
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "tags" {
  description = "Tags applied to resources"
  value       = var.tags
}

