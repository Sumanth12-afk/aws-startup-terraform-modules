resource "aws_guardduty_detector" "main" {
  enable                       = var.enable_guardduty
  finding_publishing_frequency = var.finding_publishing_frequency

  datasources {
    s3_logs {
      enable = var.enable_s3_protection
    }
    kubernetes {
      audit_logs {
        enable = var.enable_kubernetes_protection
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = var.enable_malware_protection
        }
      }
    }
  }

  tags = merge(var.tags, {
    Name        = "guardduty-detector"
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}

resource "aws_securityhub_account" "main" {
  count                   = var.enable_security_hub ? 1 : 0
  enable_default_standards = var.enable_default_standards
  control_finding_generator = "SECURITY_CONTROL"
}

resource "aws_config_configuration_recorder" "main" {
  count    = var.enable_config ? 1 : 0
  name     = var.config_recorder_name
  role_arn = aws_iam_role.config[0].arn

  recording_group {
    all_supported = true
    include_global_resource_types = var.include_global_resources
  }
}

resource "aws_config_delivery_channel" "main" {
  count          = var.enable_config ? 1 : 0
  name           = var.config_delivery_channel_name
  s3_bucket_name = aws_s3_bucket.config[0].id
  depends_on     = [aws_config_configuration_recorder.main]
}

resource "aws_config_configuration_recorder_status" "main" {
  count      = var.enable_config ? 1 : 0
  name       = aws_config_configuration_recorder.main[0].name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.main]
}

resource "aws_s3_bucket" "config" {
  count  = var.enable_config ? 1 : 0
  bucket = var.config_s3_bucket_name

  tags = merge(var.tags, {
    Name    = var.config_s3_bucket_name
    Purpose = "AWSConfig"
  })
}

resource "aws_iam_role" "config" {
  count = var.enable_config ? 1 : 0
  name  = "aws-config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "config.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/ConfigRole"
  ]

  tags = var.tags
}

resource "aws_sns_topic" "security_alerts" {
  count = var.create_sns_topic ? 1 : 0
  name  = "${var.environment}-security-alerts"

  tags = merge(var.tags, {
    Name    = "${var.environment}-security-alerts"
    Purpose = "SecurityAlerts"
  })
}

resource "aws_cloudwatch_event_rule" "guardduty_findings" {
  count       = var.enable_guardduty && var.create_sns_topic ? 1 : 0
  name        = "guardduty-findings"
  description = "Capture GuardDuty findings"

  event_pattern = jsonencode({
    source      = ["aws.guardduty"]
    detail-type = ["GuardDuty Finding"]
  })

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "sns" {
  count     = var.enable_guardduty && var.create_sns_topic ? 1 : 0
  rule      = aws_cloudwatch_event_rule.guardduty_findings[0].name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.security_alerts[0].arn
}

