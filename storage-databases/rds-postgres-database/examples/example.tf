# Example usage of the RDS PostgreSQL Database module

module "rds_postgres" {
  source = "../"

  # Environment Configuration
  environment = "production"
  aws_region  = "us-east-1"
  aws_profile = "default"

  # Remote State Configuration
  state_bucket_name = "my-terraform-state-bucket"
  state_lock_table  = "terraform-state-lock"

  # Database Configuration
  db_name     = "myapp"
  db_username = "dbadmin"
  db_port     = 5432

  # Instance Configuration
  instance_class    = "db.t4g.medium"
  allocated_storage = 100
  engine_version    = "15.3"

  # Network Configuration
  vpc_id             = "vpc-0123456789abcdef0"
  subnet_ids         = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
  allowed_cidr_blocks = ["10.0.0.0/16"]

  # High Availability
  multi_az               = true
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"

  # Performance & Monitoring
  enable_performance_insights = true
  enable_enhanced_monitoring  = true
  monitoring_interval         = 60

  # Security
  deletion_protection       = true
  skip_final_snapshot      = false
  final_snapshot_identifier = "myapp-final-snapshot"
  kms_key_id               = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"

  # Tags
  tags = {
    Project     = "MyApp"
    Owner       = "DevOps Team"
    CostCenter  = "Engineering"
    Compliance  = "HIPAA"
  }
}

# Outputs
output "db_endpoint" {
  description = "The connection endpoint"
  value       = module.rds_postgres.db_instance_endpoint
}

output "db_name" {
  description = "The database name"
  value       = module.rds_postgres.db_name
}

output "secret_arn" {
  description = "ARN of the secret containing database credentials"
  value       = module.rds_postgres.db_secret_arn
  sensitive   = true
}
