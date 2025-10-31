resource "aws_backup_vault" "main" {
  name        = "${var.environment}-backup-vault"
  kms_key_arn = var.kms_key_arn
  tags        = merge(var.tags, { Name = "${var.environment}-backup-vault", Environment = var.environment })
}

resource "aws_backup_plan" "main" {
  name = "${var.environment}-backup-plan"

  rule {
    rule_name         = "daily_backup"
    target_vault_name = aws_backup_vault.main.name
    schedule          = var.backup_schedule
    start_window      = 60
    completion_window = 120

    lifecycle {
      delete_after = var.retention_days
    }

    copy_action {
      destination_vault_arn = var.copy_to_vault_arn != null ? var.copy_to_vault_arn : aws_backup_vault.main.arn

      lifecycle {
        delete_after = var.retention_days
      }
    }
  }

  tags = merge(var.tags, { Name = "${var.environment}-backup-plan" })
}

resource "aws_backup_selection" "main" {
  iam_role_arn = aws_iam_role.backup.arn
  name         = "${var.environment}-backup-selection"
  plan_id      = aws_backup_plan.main.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Backup"
    value = "true"
  }

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Environment"
    value = var.environment
  }
}

resource "aws_iam_role" "backup" {
  name = "${var.environment}-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "backup.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup",
    "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
  ]

  tags = var.tags
}

resource "aws_sns_topic" "backup_notifications" {
  name = "${var.environment}-backup-notifications"
  tags = merge(var.tags, { Name = "${var.environment}-backup-notifications" })
}

resource "aws_backup_vault_notifications" "main" {
  backup_vault_name   = aws_backup_vault.main.name
  sns_topic_arn       = aws_sns_topic.backup_notifications.arn
  backup_vault_events = ["BACKUP_JOB_COMPLETED", "RESTORE_JOB_COMPLETED", "BACKUP_JOB_FAILED", "RESTORE_JOB_FAILED"]
}

