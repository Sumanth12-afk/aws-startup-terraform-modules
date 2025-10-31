# Replication Group Outputs
output "replication_group_id" {
  description = "The ID of the ElastiCache Replication Group"
  value       = var.cluster_mode_enabled ? aws_elasticache_replication_group.redis_cluster[0].id : aws_elasticache_replication_group.redis[0].id
}

output "replication_group_arn" {
  description = "The ARN of the ElastiCache Replication Group"
  value       = var.cluster_mode_enabled ? aws_elasticache_replication_group.redis_cluster[0].arn : aws_elasticache_replication_group.redis[0].arn
}

output "primary_endpoint_address" {
  description = "The address of the primary endpoint"
  value       = var.cluster_mode_enabled ? aws_elasticache_replication_group.redis_cluster[0].configuration_endpoint_address : aws_elasticache_replication_group.redis[0].primary_endpoint_address
}

output "reader_endpoint_address" {
  description = "The address of the reader endpoint"
  value       = var.cluster_mode_enabled ? null : aws_elasticache_replication_group.redis[0].reader_endpoint_address
}

output "configuration_endpoint_address" {
  description = "The configuration endpoint address (cluster mode only)"
  value       = var.cluster_mode_enabled ? aws_elasticache_replication_group.redis_cluster[0].configuration_endpoint_address : null
}

output "port" {
  description = "The port number on which the cache accepts connections"
  value       = var.port
}

# Security Group Outputs
output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.redis.id
}

output "security_group_arn" {
  description = "The ARN of the security group"
  value       = aws_security_group.redis.arn
}

# Subnet Group Outputs
output "subnet_group_name" {
  description = "The name of the subnet group"
  value       = aws_elasticache_subnet_group.redis.name
}

output "subnet_group_arn" {
  description = "The ARN of the subnet group"
  value       = aws_elasticache_subnet_group.redis.arn
}

# Parameter Group Outputs
output "parameter_group_name" {
  description = "The name of the parameter group"
  value       = aws_elasticache_parameter_group.redis.name
}

output "parameter_group_arn" {
  description = "The ARN of the parameter group"
  value       = aws_elasticache_parameter_group.redis.arn
}

# CloudWatch Alarm ARNs
output "cloudwatch_alarm_arns" {
  description = "ARNs of CloudWatch alarms"
  value = {
    cpu_utilization    = aws_cloudwatch_metric_alarm.cpu_utilization.arn
    memory_utilization = aws_cloudwatch_metric_alarm.memory_utilization.arn
    evictions          = aws_cloudwatch_metric_alarm.evictions.arn
    replication_lag    = aws_cloudwatch_metric_alarm.replication_lag.arn
  }
}

# Connection String
output "connection_string" {
  description = "Redis connection string"
  value       = var.transit_encryption_enabled ? "rediss://${var.cluster_mode_enabled ? aws_elasticache_replication_group.redis_cluster[0].configuration_endpoint_address : aws_elasticache_replication_group.redis[0].primary_endpoint_address}:${var.port}" : "redis://${var.cluster_mode_enabled ? aws_elasticache_replication_group.redis_cluster[0].configuration_endpoint_address : aws_elasticache_replication_group.redis[0].primary_endpoint_address}:${var.port}"
}

# Configuration Information
output "cluster_mode_enabled" {
  description = "Whether cluster mode is enabled"
  value       = var.cluster_mode_enabled
}

output "encryption_at_rest_enabled" {
  description = "Whether encryption at rest is enabled"
  value       = var.at_rest_encryption_enabled
}

output "encryption_in_transit_enabled" {
  description = "Whether encryption in transit is enabled"
  value       = var.transit_encryption_enabled
}

