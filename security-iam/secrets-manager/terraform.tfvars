environment = "production"
aws_region  = "us-east-1"

secret_name = "database-credentials"
description = "RDS database credentials"

# Secret value (JSON format for structured data)
# secret_string = jsonencode({
#   username = "admin"
#   password = "changeme"
#   host     = "mydb.123456.us-east-1.rds.amazonaws.com"
#   port     = 5432
# })

# Encryption
# kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/abc123"

# Rotation
enable_rotation = false
# rotation_lambda_arn = "arn:aws:lambda:us-east-1:123456789012:function:rotate-secret"
rotation_days   = 30

recovery_window_in_days = 30

tags = {
  Project = "MyApp"
  Type    = "DatabaseCredentials"
}

