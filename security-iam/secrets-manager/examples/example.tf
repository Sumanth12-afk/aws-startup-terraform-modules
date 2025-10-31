module "db_secret" {
  source = "../"

  environment = "production"
  secret_name = "database-credentials"
  description = "RDS database credentials"

  secret_string = jsonencode({
    username = "admin"
    password = var.db_password
    host     = module.rds.endpoint
    port     = 5432
  })

  kms_key_id = module.kms.key_id

  tags = {
    Project = "MyApp"
    Type    = "Database"
  }
}

output "secret_arn" {
  value     = module.db_secret.secret_arn
  sensitive = true
}

