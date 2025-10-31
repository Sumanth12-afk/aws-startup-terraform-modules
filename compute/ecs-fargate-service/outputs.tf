# ECS Fargate Service Module - Outputs

# Cluster Outputs
output "cluster_id" {
  description = "ID of the ECS cluster"
  value       = local.cluster_id
}

output "cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = local.cluster_arn
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = local.cluster_name
}

# Service Outputs
output "service_id" {
  description = "ID of the ECS service"
  value       = aws_ecs_service.main.id
}

output "service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.main.name
}

output "service_arn" {
  description = "ARN of the ECS service"
  value       = aws_ecs_service.main.arn
}

# Task Definition Outputs
output "task_definition_arn" {
  description = "ARN of the task definition"
  value       = aws_ecs_task_definition.main.arn
}

output "task_definition_family" {
  description = "Family of the task definition"
  value       = aws_ecs_task_definition.main.family
}

output "task_definition_revision" {
  description = "Revision of the task definition"
  value       = aws_ecs_task_definition.main.revision
}

# IAM Role Outputs
output "task_role_arn" {
  description = "ARN of the task IAM role"
  value       = local.task_role_arn
}

output "task_role_name" {
  description = "Name of the task IAM role"
  value       = var.task_role_arn == "" ? aws_iam_role.task[0].name : null
}

output "execution_role_arn" {
  description = "ARN of the task execution IAM role"
  value       = local.execution_role_arn
}

output "execution_role_name" {
  description = "Name of the task execution IAM role"
  value       = var.execution_role_arn == "" ? aws_iam_role.execution[0].name : null
}

# Security Group Outputs
output "security_group_id" {
  description = "ID of the ECS tasks security group"
  value       = aws_security_group.ecs_tasks.id
}

output "security_group_arn" {
  description = "ARN of the ECS tasks security group"
  value       = aws_security_group.ecs_tasks.arn
}

# CloudWatch Logs Outputs
output "log_group_name" {
  description = "Name of the CloudWatch Log Group"
  value       = var.enable_logging ? aws_cloudwatch_log_group.main[0].name : null
}

output "log_group_arn" {
  description = "ARN of the CloudWatch Log Group"
  value       = var.enable_logging ? aws_cloudwatch_log_group.main[0].arn : null
}

# Service Discovery Outputs
output "service_discovery_arn" {
  description = "ARN of the service discovery service"
  value       = var.enable_service_discovery ? aws_service_discovery_service.main[0].arn : null
}

output "service_discovery_id" {
  description = "ID of the service discovery service"
  value       = var.enable_service_discovery ? aws_service_discovery_service.main[0].id : null
}

# Auto Scaling Outputs
output "autoscaling_target_id" {
  description = "Resource ID of the autoscaling target"
  value       = var.enable_autoscaling ? aws_appautoscaling_target.ecs[0].id : null
}

output "autoscaling_policy_cpu_arn" {
  description = "ARN of the CPU autoscaling policy"
  value       = var.enable_autoscaling ? aws_appautoscaling_policy.ecs_cpu[0].arn : null
}

output "autoscaling_policy_memory_arn" {
  description = "ARN of the memory autoscaling policy"
  value       = var.enable_autoscaling ? aws_appautoscaling_policy.ecs_memory[0].arn : null
}

# Container Information
output "container_name" {
  description = "Name of the container"
  value       = local.container_name
}

output "container_port" {
  description = "Port exposed by the container"
  value       = var.container_port
}

# Metadata
output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "tags" {
  description = "Tags applied to resources"
  value       = var.tags
}

