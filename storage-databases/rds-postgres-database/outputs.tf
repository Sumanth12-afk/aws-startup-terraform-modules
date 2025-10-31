# RDS PostgreSQL Database Module - Outputs

# Instance Outputs
output "db_instance_id" {
  description = "ID of the RDS instance"
  value       = aws_db_instance.main.id
}

output "db_instance_arn" {
  description = "ARN of the RDS instance"
  value       = aws_db_instance.main.arn
}

output "db_instance_endpoint" {
  description = "Connection endpoint for the RDS instance"
  value       = aws_db_instance.main.endpoint
}

output "db_instance_address" {
  description = "Address of the RDS instance"
  value       = aws_db_instance.main.address
}

output "db_instance_port" {
  description = "Port of the RDS instance"
  value       = aws_db_instance.main.port
}

output "db_instance_name" {
  description = "Database name"
  value       = aws_db_instance.main.db_name
}

output "db_instance_username" {
  description = "Master username"
  value       = aws_db_instance.main.username
  sensitive   = true
}

output "db_instance_resource_id" {
  description = "Resource ID of the RDS instance"
  value       = aws_db_instance.main.resource_id
}

# Connection String
output "connection_string" {
  description = "PostgreSQL connection string"
  value       = "postgresql://${aws_db_instance.main.username}@${aws_db_instance.main.endpoint}/${aws_db_instance.main.db_name}"
  sensitive   = true
}

# Read Replica Outputs
output "read_replica_endpoints" {
  description = "Endpoints of read replicas"
  value       = aws_db_instance.replica[*].endpoint
}

output "read_replica_ids" {
  description = "IDs of read replicas"
  value       = aws_db_instance.replica[*].id
}

# Security Group Outputs
output "security_group_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds.id
}

output "security_group_arn" {
  description = "ARN of the RDS security group"
  value       = aws_security_group.rds.arn
}

# Subnet Group Output
output "db_subnet_group_name" {
  description = "Name of the DB subnet group"
  value       = aws_db_subnet_group.main.name
}

output "db_subnet_group_id" {
  description = "ID of the DB subnet group"
  value       = aws_db_subnet_group.main.id
}

# Parameter Group Output
output "parameter_group_name" {
  description = "Name of the DB parameter group"
  value       = aws_db_parameter_group.main.name
}

output "parameter_group_id" {
  description = "ID of the DB parameter group"
  value       = aws_db_parameter_group.main.id
}

# KMS Key Output
output "kms_key_id" {
  description = "KMS key ID used for encryption"
  value       = local.kms_key_id
}

# Monitoring Role Output
output "monitoring_role_arn" {
  description = "ARN of the enhanced monitoring IAM role"
  value       = var.monitoring_interval > 0 ? aws_iam_role.rds_monitoring[0].arn : null
}

# CloudWatch Alarm Outputs
output "cpu_alarm_arn" {
  description = "ARN of the CPU utilization alarm"
  value       = var.environment == "production" ? aws_cloudwatch_metric_alarm.cpu_high[0].arn : null
}

output "storage_alarm_arn" {
  description = "ARN of the storage space alarm"
  value       = var.environment == "production" ? aws_cloudwatch_metric_alarm.storage_low[0].arn : null
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

