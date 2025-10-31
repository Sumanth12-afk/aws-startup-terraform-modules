# Environment Configuration
environment = "production"
aws_region  = "us-east-1"
aws_profile = "default"

# Remote State Configuration (uncomment for production)
# state_bucket_name = "my-terraform-state-bucket"
# state_lock_table  = "terraform-state-lock"

# DynamoDB Table Configuration
table_name   = "users-production"
billing_mode = "PAY_PER_REQUEST"

# For provisioned capacity (uncomment if using PROVISIONED mode)
# billing_mode   = "PROVISIONED"
# read_capacity  = 10
# write_capacity = 10

# Schema Configuration
hash_key      = "user_id"
hash_key_type = "S"
range_key      = "created_at"
range_key_type = "N"

# Additional attributes for GSI
attributes = [
  {
    name = "email"
    type = "S"
  },
  {
    name = "status"
    type = "S"
  }
]

# Global Secondary Index
global_secondary_indexes = [
  {
    name            = "email-index"
    hash_key        = "email"
    projection_type = "ALL"
  },
  {
    name            = "status-index"
    hash_key        = "status"
    range_key       = "created_at"
    projection_type = "KEYS_ONLY"
  }
]

# Time To Live
enable_ttl         = true
ttl_attribute_name = "expires_at"

# Point-in-Time Recovery
enable_point_in_time_recovery = true

# Encryption
enable_encryption = true
# kms_key_arn       = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"

# Streams
enable_streams    = true
stream_view_type  = "NEW_AND_OLD_IMAGES"

# Auto Scaling (only for PROVISIONED mode)
enable_autoscaling            = false
autoscaling_read_target       = 70
autoscaling_read_min_capacity = 5
autoscaling_read_max_capacity = 100
autoscaling_write_target       = 70
autoscaling_write_min_capacity = 5
autoscaling_write_max_capacity = 100

# Deletion Protection
deletion_protection_enabled = true

# Table Class
table_class = "STANDARD"

# Global Tables (multi-region replication)
replica_regions = []
# replica_regions = ["us-west-2", "eu-west-1"]

# Tags
tags = {
  Project     = "MyApp"
  Owner       = "Backend Team"
  CostCenter  = "Engineering"
  Environment = "production"
}

