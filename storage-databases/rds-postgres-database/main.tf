# RDS PostgreSQL Database Module - Production-Ready Managed Database

terraform {
  required_version = ">= 1.5.0"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ========================================
# DB Subnet Group
# ========================================

resource "aws_db_subnet_group" "main" {
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.database_subnet_ids

  tags = merge(
    var.tags,
    {
      Name        = "${var.identifier}-subnet-group"
      Environment = var.environment
    }
  )
}

# ========================================
# Security Group
# ========================================

resource "aws_security_group" "rds" {
  name_prefix = "${var.identifier}-rds-"
  description = "Security group for RDS PostgreSQL ${var.identifier}"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name        = "${var.identifier}-rds-sg"
      Environment = var.environment
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Allow ingress from security groups
resource "aws_security_group_rule" "rds_ingress_sg" {
  count = length(var.allowed_security_group_ids)

  type                     = "ingress"
  from_port                = var.port
  to_port                  = var.port
  protocol                 = "tcp"
  source_security_group_id = var.allowed_security_group_ids[count.index]
  security_group_id        = aws_security_group.rds.id
  description              = "Allow PostgreSQL access from application security groups"
}

# Allow ingress from CIDR blocks
resource "aws_security_group_rule" "rds_ingress_cidr" {
  count = length(var.allowed_cidr_blocks) > 0 ? 1 : 0

  type              = "ingress"
  from_port         = var.port
  to_port           = var.port
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = aws_security_group.rds.id
  description       = "Allow PostgreSQL access from specified CIDR blocks"
}

# ========================================
# Parameter Group
# ========================================

resource "aws_db_parameter_group" "main" {
  name_prefix = "${var.identifier}-pg-"
  family      = var.parameter_group_family
  description = "Custom parameter group for ${var.identifier}"

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.identifier}-parameter-group"
      Environment = var.environment
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ========================================
# KMS Key (Optional)
# ========================================

resource "aws_kms_key" "rds" {
  count = var.storage_encrypted && var.kms_key_id == "" ? 1 : 0

  description             = "KMS key for RDS ${var.identifier}"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = merge(
    var.tags,
    {
      Name        = "${var.identifier}-rds-kms"
      Environment = var.environment
    }
  )
}

resource "aws_kms_alias" "rds" {
  count = var.storage_encrypted && var.kms_key_id == "" ? 1 : 0

  name          = "alias/${var.identifier}-rds"
  target_key_id = aws_kms_key.rds[0].key_id
}

locals {
  kms_key_id = var.storage_encrypted ? (var.kms_key_id != "" ? var.kms_key_id : aws_kms_key.rds[0].arn) : null
}

# ========================================
# RDS Instance
# ========================================

resource "aws_db_instance" "main" {
  identifier = var.identifier

  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = var.storage_encrypted
  kms_key_id            = local.kms_key_id

  db_name  = var.database_name
  username = var.master_username
  password = var.master_password
  port     = var.port

  multi_az               = var.multi_az
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.main.name

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window

  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.final_snapshot_identifier_prefix}-${var.identifier}-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  monitoring_interval             = var.monitoring_interval
  monitoring_role_arn             = var.monitoring_interval > 0 ? aws_iam_role.rds_monitoring[0].arn : null

  performance_insights_enabled          = var.enable_performance_insights
  performance_insights_retention_period = var.enable_performance_insights ? var.performance_insights_retention_period : null

  auto_minor_version_upgrade = true
  copy_tags_to_snapshot      = true
  deletion_protection        = var.environment == "production"
  publicly_accessible        = false

  tags = merge(
    var.tags,
    {
      Name        = var.identifier
      Environment = var.environment
    }
  )
}

# ========================================
# Read Replicas
# ========================================

resource "aws_db_instance" "replica" {
  count = var.create_read_replica ? var.read_replica_count : 0

  identifier = "${var.identifier}-replica-${count.index + 1}"

  replicate_source_db = aws_db_instance.main.identifier
  instance_class      = var.instance_class

  auto_minor_version_upgrade = true
  publicly_accessible        = false
  skip_final_snapshot        = true

  performance_insights_enabled          = var.enable_performance_insights
  performance_insights_retention_period = var.enable_performance_insights ? var.performance_insights_retention_period : null

  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_interval > 0 ? aws_iam_role.rds_monitoring[0].arn : null

  tags = merge(
    var.tags,
    {
      Name        = "${var.identifier}-replica-${count.index + 1}"
      Environment = var.environment
      Type        = "read-replica"
    }
  )
}

# ========================================
# Enhanced Monitoring IAM Role
# ========================================

resource "aws_iam_role" "rds_monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0

  name_prefix = "${var.identifier}-rds-monitoring-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name        = "${var.identifier}-rds-monitoring-role"
      Environment = var.environment
    }
  )
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0

  role       = aws_iam_role.rds_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# ========================================
# CloudWatch Alarms
# ========================================

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count = var.environment == "production" ? 1 : 0

  alarm_name          = "${var.identifier}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "RDS CPU utilization is too high"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.identifier}-cpu-alarm"
      Environment = var.environment
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "storage_low" {
  count = var.environment == "production" ? 1 : 0

  alarm_name          = "${var.identifier}-storage-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 5000000000 # 5 GB in bytes
  alarm_description   = "RDS free storage space is running low"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.identifier}-storage-alarm"
      Environment = var.environment
    }
  )
}

