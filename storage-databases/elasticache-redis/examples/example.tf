# Example usage of the ElastiCache Redis module

# Simple Redis cache (single node)
module "simple_cache" {
  source = "../"

  environment = "development"
  cluster_id  = "simple-cache"

  node_type       = "cache.t4g.micro"
  num_cache_nodes = 1

  vpc_id              = "vpc-0123456789abcdef0"
  subnet_ids          = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
  allowed_cidr_blocks = ["10.0.0.0/16"]

  automatic_failover_enabled = false
  multi_az_enabled           = false

  tags = {
    Project = "MyApp"
  }
}

# Production Redis with HA (primary + replica)
module "production_cache" {
  source = "../"

  environment = "production"
  aws_region  = "us-east-1"
  cluster_id  = "myapp-prod"

  engine_version         = "7.0"
  node_type              = "cache.r6g.large"
  num_cache_nodes        = 2  # Primary + 1 replica
  parameter_group_family = "redis7"

  vpc_id                      = module.vpc.vpc_id
  subnet_ids                  = module.vpc.private_subnet_ids
  allowed_security_group_ids  = [module.app.security_group_id]

  # High Availability
  automatic_failover_enabled = true
  multi_az_enabled           = true

  # Backups
  snapshot_retention_limit = 7
  snapshot_window          = "03:00-05:00"

  # Security
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  auth_token                 = var.redis_auth_token

  # Custom parameters
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

  tags = {
    Project = "MyApp"
    Owner   = "Backend"
  }
}

# Redis Cluster Mode (sharded)
module "cluster_mode_cache" {
  source = "../"

  environment = "production"
  cluster_id  = "myapp-cluster"

  node_type              = "cache.r6g.xlarge"
  cluster_mode_enabled   = true
  num_node_groups        = 3  # 3 shards
  replicas_per_node_group = 2  # 2 replicas per shard

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  automatic_failover_enabled = true
  multi_az_enabled           = true

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  tags = {
    Project = "MyApp"
    Type    = "ClusterMode"
  }
}

# Outputs
output "simple_cache_endpoint" {
  value = module.simple_cache.primary_endpoint_address
}

output "production_cache_connection_string" {
  value     = module.production_cache.connection_string
  sensitive = true
}

output "cluster_mode_endpoint" {
  value = module.cluster_mode_cache.configuration_endpoint_address
}

