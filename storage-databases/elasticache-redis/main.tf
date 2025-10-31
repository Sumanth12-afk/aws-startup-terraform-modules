# Data Sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  common_tags = merge(
    var.tags,
    {
      Name        = var.cluster_id
      Environment = var.environment
      ManagedBy   = "Terraform"
      Module      = "elasticache-redis"
    }
  )
}

#---------------------------------------------------------------
# Security Group
#---------------------------------------------------------------

resource "aws_security_group" "redis" {
  name_prefix = "${var.cluster_id}-redis-"
  description = "Security group for ElastiCache Redis cluster ${var.cluster_id}"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.cluster_id}-redis-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "redis_from_sg" {
  count                        = length(var.allowed_security_group_ids)
  security_group_id            = aws_security_group.redis.id
  referenced_security_group_id = var.allowed_security_group_ids[count.index]
  from_port                    = var.port
  to_port                      = var.port
  ip_protocol                  = "tcp"
  description                  = "Allow Redis access from security group ${count.index}"

  tags = local.common_tags
}

resource "aws_vpc_security_group_ingress_rule" "redis_from_cidr" {
  count             = length(var.allowed_cidr_blocks)
  security_group_id = aws_security_group.redis.id
  cidr_ipv4         = var.allowed_cidr_blocks[count.index]
  from_port         = var.port
  to_port           = var.port
  ip_protocol       = "tcp"
  description       = "Allow Redis access from CIDR ${var.allowed_cidr_blocks[count.index]}"

  tags = local.common_tags
}

resource "aws_vpc_security_group_egress_rule" "redis_egress" {
  security_group_id = aws_security_group.redis.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all outbound traffic"

  tags = local.common_tags
}

#---------------------------------------------------------------
# Subnet Group
#---------------------------------------------------------------

resource "aws_elasticache_subnet_group" "redis" {
  name        = "${var.cluster_id}-subnet-group"
  description = "Subnet group for ElastiCache Redis cluster ${var.cluster_id}"
  subnet_ids  = var.subnet_ids

  tags = local.common_tags
}

#---------------------------------------------------------------
# Parameter Group
#---------------------------------------------------------------

resource "aws_elasticache_parameter_group" "redis" {
  family      = var.parameter_group_family
  name        = "${var.cluster_id}-params"
  description = "Parameter group for ElastiCache Redis cluster ${var.cluster_id}"

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = local.common_tags

  lifecycle {
    create_before_destroy = true
  }
}

#---------------------------------------------------------------
# Replication Group (Cluster Mode Disabled)
#---------------------------------------------------------------

resource "aws_elasticache_replication_group" "redis" {
  count = var.cluster_mode_enabled ? 0 : 1

  replication_group_id       = var.cluster_id
  description                = "Redis replication group for ${var.cluster_id}"
  engine                     = "redis"
  engine_version             = var.engine_version
  node_type                  = var.node_type
  port                       = var.port
  parameter_group_name       = aws_elasticache_parameter_group.redis.name
  subnet_group_name          = aws_elasticache_subnet_group.redis.name
  security_group_ids         = [aws_security_group.redis.id]
  num_cache_clusters         = var.num_cache_nodes
  automatic_failover_enabled = var.num_cache_nodes > 1 ? var.automatic_failover_enabled : false
  multi_az_enabled           = var.num_cache_nodes > 1 ? var.multi_az_enabled : false
  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  transit_encryption_enabled = var.transit_encryption_enabled
  auth_token                 = var.transit_encryption_enabled ? var.auth_token : null
  kms_key_id                 = var.kms_key_id
  snapshot_retention_limit   = var.snapshot_retention_limit
  snapshot_window            = var.snapshot_window
  maintenance_window         = var.maintenance_window
  final_snapshot_identifier  = var.final_snapshot_identifier
  notification_topic_arn     = var.notification_topic_arn
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  apply_immediately          = var.apply_immediately
  data_tiering_enabled       = var.data_tiering_enabled

  dynamic "log_delivery_configuration" {
    for_each = var.log_delivery_configuration
    content {
      destination      = log_delivery_configuration.value.destination
      destination_type = log_delivery_configuration.value.destination_type
      log_format       = log_delivery_configuration.value.log_format
      log_type         = log_delivery_configuration.value.log_type
    }
  }

  tags = local.common_tags
}

#---------------------------------------------------------------
# Replication Group (Cluster Mode Enabled)
#---------------------------------------------------------------

resource "aws_elasticache_replication_group" "redis_cluster" {
  count = var.cluster_mode_enabled ? 1 : 0

  replication_group_id       = var.cluster_id
  description                = "Redis cluster mode replication group for ${var.cluster_id}"
  engine                     = "redis"
  engine_version             = var.engine_version
  node_type                  = var.node_type
  port                       = var.port
  parameter_group_name       = aws_elasticache_parameter_group.redis.name
  subnet_group_name          = aws_elasticache_subnet_group.redis.name
  security_group_ids         = [aws_security_group.redis.id]
  num_node_groups            = var.num_node_groups
  replicas_per_node_group    = var.replicas_per_node_group
  automatic_failover_enabled = true
  multi_az_enabled           = var.multi_az_enabled
  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  transit_encryption_enabled = var.transit_encryption_enabled
  auth_token                 = var.transit_encryption_enabled ? var.auth_token : null
  kms_key_id                 = var.kms_key_id
  snapshot_retention_limit   = var.snapshot_retention_limit
  snapshot_window            = var.snapshot_window
  maintenance_window         = var.maintenance_window
  final_snapshot_identifier  = var.final_snapshot_identifier
  notification_topic_arn     = var.notification_topic_arn
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  apply_immediately          = var.apply_immediately
  data_tiering_enabled       = var.data_tiering_enabled

  dynamic "log_delivery_configuration" {
    for_each = var.log_delivery_configuration
    content {
      destination      = log_delivery_configuration.value.destination
      destination_type = log_delivery_configuration.value.destination_type
      log_format       = log_delivery_configuration.value.log_format
      log_type         = log_delivery_configuration.value.log_type
    }
  }

  tags = local.common_tags
}

#---------------------------------------------------------------
# CloudWatch Alarms
#---------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  alarm_name          = "${var.cluster_id}-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = "300"
  statistic           = "Average"
  threshold           = "75"
  alarm_description   = "Monitors ElastiCache CPU utilization"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ReplicationGroupId = var.cluster_id
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "memory_utilization" {
  alarm_name          = "${var.cluster_id}-memory-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "DatabaseMemoryUsagePercentage"
  namespace           = "AWS/ElastiCache"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Monitors ElastiCache memory utilization"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ReplicationGroupId = var.cluster_id
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "evictions" {
  alarm_name          = "${var.cluster_id}-evictions"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Evictions"
  namespace           = "AWS/ElastiCache"
  period              = "300"
  statistic           = "Sum"
  threshold           = "100"
  alarm_description   = "Monitors ElastiCache evictions"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ReplicationGroupId = var.cluster_id
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "replication_lag" {
  alarm_name          = "${var.cluster_id}-replication-lag"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ReplicationLag"
  namespace           = "AWS/ElastiCache"
  period              = "300"
  statistic           = "Average"
  threshold           = "30"
  alarm_description   = "Monitors ElastiCache replication lag"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ReplicationGroupId = var.cluster_id
  }

  tags = local.common_tags
}

