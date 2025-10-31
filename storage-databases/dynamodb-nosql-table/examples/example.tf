# Example usage of the DynamoDB NoSQL Table module

# Simple table with on-demand billing
module "simple_table" {
  source = "../"

  environment  = "production"
  table_name   = "simple-users"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "id"

  enable_point_in_time_recovery = true
  enable_encryption              = true

  tags = {
    Project = "MyApp"
  }
}

# Advanced table with GSI and provisioned capacity
module "advanced_table" {
  source = "../"

  environment = "production"
  aws_region  = "us-east-1"

  table_name     = "users"
  billing_mode   = "PROVISIONED"
  read_capacity  = 10
  write_capacity = 10

  hash_key      = "user_id"
  hash_key_type = "S"
  range_key      = "created_at"
  range_key_type = "N"

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

  global_secondary_indexes = [
    {
      name               = "email-index"
      hash_key           = "email"
      projection_type    = "ALL"
      read_capacity      = 5
      write_capacity     = 5
    },
    {
      name               = "status-index"
      hash_key           = "status"
      range_key          = "created_at"
      projection_type    = "KEYS_ONLY"
      read_capacity      = 5
      write_capacity     = 5
    }
  ]

  enable_ttl         = true
  ttl_attribute_name = "expires_at"

  enable_streams   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  enable_autoscaling            = true
  autoscaling_read_min_capacity = 5
  autoscaling_read_max_capacity = 100
  autoscaling_write_min_capacity = 5
  autoscaling_write_max_capacity = 100

  enable_point_in_time_recovery = true
  deletion_protection_enabled    = true

  tags = {
    Project = "MyApp"
    Owner   = "Backend"
  }
}

# Global Table (multi-region)
module "global_table" {
  source = "../"

  environment  = "production"
  table_name   = "global-sessions"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "session_id"

  replica_regions = ["us-west-2", "eu-west-1"]

  enable_streams   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  enable_point_in_time_recovery = true

  tags = {
    Project = "GlobalApp"
    Type    = "GlobalTable"
  }
}

# Outputs
output "simple_table_arn" {
  value = module.simple_table.table_arn
}

output "advanced_table_name" {
  value = module.advanced_table.table_name
}

output "global_table_stream_arn" {
  value = module.global_table.table_stream_arn
}

