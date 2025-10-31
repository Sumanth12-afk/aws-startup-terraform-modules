module "database_kms" {
  source = "../"

  environment = "production"
  key_alias   = "database-encryption"
  description = "KMS key for RDS encryption"

  enable_key_rotation = true

  key_administrators = [
    "arn:aws:iam::123456789012:role/Admin"
  ]

  key_users = [
    "arn:aws:iam::123456789012:role/RDSEnhancedMonitoring"
  ]

  tags = {
    Project = "MyApp"
    Purpose = "Database"
  }
}

output "key_arn" {
  value = module.database_kms.key_arn
}

