environment  = "production"
aws_region   = "us-east-1"
key_alias    = "database-encryption"
description  = "KMS key for RDS database encryption"

enable_key_rotation     = true
deletion_window_in_days = 30

key_administrators = ["arn:aws:iam::123456789012:role/Admin"]
key_users         = ["arn:aws:iam::123456789012:role/ECSTaskRole"]

tags = {
  Project = "MyApp"
  Purpose = "DatabaseEncryption"
}

