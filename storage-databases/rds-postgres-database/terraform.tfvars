# Example Terraform Variables for RDS PostgreSQL Database

# AWS Configuration
aws_region        = "us-east-1"
state_bucket_name = "my-company-terraform-state"
state_lock_table  = "terraform-state-locks"
environment       = "production"
project_name      = "my-startup"

# Database Configuration
identifier      = "my-app-db"
engine_version  = "15.4"
instance_class  = "db.t4g.medium"  # Use db.t4g.micro for dev

allocated_storage     = 20
max_allocated_storage = 100  # Auto-scaling up to 100 GB

database_name   = "myapp_production"
master_username = "dbadmin"
master_password = "CHANGE_ME_IN_PRODUCTION"  # Use Secrets Manager!

# High Availability
multi_az             = true   # Set false for dev
create_read_replica  = true
read_replica_count   = 1

# Backup & Maintenance
backup_retention_period = 7     # Days
backup_window           = "03:00-04:00"  # UTC
maintenance_window      = "sun:04:00-sun:05:00"  # UTC

skip_final_snapshot = false  # Set true for dev
final_snapshot_identifier_prefix = "final-snapshot"

# Networking
vpc_id             = "vpc-12345678"
database_subnet_ids = ["subnet-abc123", "subnet-def456", "subnet-ghi789"]

# Security - Allow access from ECS security group
allowed_security_group_ids = ["sg-ecs123456"]
allowed_cidr_blocks        = []  # Prefer security groups

# Performance & Monitoring
enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
enable_performance_insights     = true
performance_insights_retention_period = 7
monitoring_interval = 60  # Enhanced monitoring

# Parameters (optional customizations)
parameter_group_family = "postgres15"
parameters = [
  # {
  #   name  = "max_connections"
  #   value = "200"
  # }
]

# Encryption
storage_encrypted = true
kms_key_id        = ""  # Leave empty to create new KMS key

# Tags
tags = {
  Team       = "platform"
  CostCenter = "engineering"
  Compliance = "hipaa"
}

