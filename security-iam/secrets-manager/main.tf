data "aws_caller_identity" "current" {}

resource "aws_secretsmanager_secret" "main" {
  name                    = var.secret_name
  description             = var.description
  kms_key_id             = var.kms_key_id
  recovery_window_in_days = var.recovery_window_in_days

  tags = merge(
    var.tags,
    {
      Name        = var.secret_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_secretsmanager_secret_version" "main" {
  count         = var.secret_string != null || var.secret_binary != null ? 1 : 0
  secret_id     = aws_secretsmanager_secret.main.id
  secret_string = var.secret_string
  secret_binary = var.secret_binary
}

resource "aws_secretsmanager_secret_rotation" "main" {
  count               = var.enable_rotation ? 1 : 0
  secret_id           = aws_secretsmanager_secret.main.id
  rotation_lambda_arn = var.rotation_lambda_arn

  rotation_rules {
    automatically_after_days = var.rotation_days
  }
}

resource "aws_secretsmanager_secret_policy" "main" {
  count      = var.secret_policy != null ? 1 : 0
  secret_arn = aws_secretsmanager_secret.main.arn
  policy     = var.secret_policy
}

