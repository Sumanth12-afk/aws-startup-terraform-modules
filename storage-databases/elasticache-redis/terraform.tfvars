# Environment Configuration
environment = "production"
aws_region  = "us-east-1"
aws_profile = "default"

# Remote State Configuration (uncomment for production)
# state_bucket_name = "my-terraform-state-bucket"
# state_lock_table  = "terraform-state-lock"

# Cluster Configuration
cluster_id             = "myapp-redis-prod"
engine_version         = "7.0"
node_type              = "cache.r6g.large"
parameter_group_family = "redis7"

# Cluster Mode (choose one configuration)
cluster_mode_enabled = false
num_cache_nodes      = 2 # Primary + 1 replica

# For cluster mode enabled (uncomment):
# cluster_mode_enabled     = true
# num_node_groups          = 3  # Number of shards
# replicas_per_node_group  = 1  # Replicas per shard

# Network Configuration
vpc_id              = "vpc-0123456789abcdef0"
subnet_ids          = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
allowed_cidr_blocks = ["10.0.0.0/16"]
port                = 6379

# High Availability
automatic_failover_enabled = true
multi_az_enabled           = true

# Backup and Maintenance
snapshot_retention_limit = 7
snapshot_window          = "03:00-05:00"
maintenance_window       = "sun:05:00-sun:07:00"
# final_snapshot_identifier = "myapp-redis-final-snapshot"

# Security
at_rest_encryption_enabled = true
transit_encryption_enabled = true
# auth_token                 = "your-secure-auth-token-here"  # Must be 16-128 characters
# kms_key_id                 = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"

# Monitoring
# notification_topic_arn = "arn:aws:sns:us-east-1:123456789012:elasticache-notifications"

# CloudWatch Logs (optional)
log_delivery_configuration = []
# log_delivery_configuration = [
#   {
#     destination      = "my-log-group"
#     destination_type = "cloudwatch-logs"
#     log_format       = "json"
#     log_type         = "slow-log"
#   }
# ]

# Custom Parameters
parameters = [
  {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  },
  {
    name  = "timeout"
    value = "300"
  }
]

# Auto Minor Version Upgrade
auto_minor_version_upgrade = true
apply_immediately          = false

# Data Tiering (only for r6gd node types)
data_tiering_enabled = false

# Tags
tags = {
  Project     = "MyApp"
  Owner       = "Backend Team"
  CostCenter  = "Engineering"
  Environment = "production"
}

