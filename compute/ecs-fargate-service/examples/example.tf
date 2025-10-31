# Example: ECS Fargate Service Module Usage

# Prerequisites: VPC and ALB
module "vpc" {
  source = "../../../networking/vpc-networking"

  environment        = "production"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

module "alb" {
  source = "../../../networking/alb-loadbalancer"

  name       = "app-alb"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids

  enable_https           = true
  certificate_arn        = "arn:aws:acm:us-east-1:123456789012:certificate/xxx"
  http_redirect_to_https = true
}

# Example 1: Basic ECS Fargate Service
module "ecs_service_basic" {
  source = "../"

  # AWS Configuration
  aws_region   = "us-east-1"
  environment  = "production"
  project_name = "my-startup"

  # ECS Cluster
  cluster_name              = "production-cluster"
  create_cluster            = true
  enable_container_insights = true

  # Service Configuration
  service_name    = "api-service"
  desired_count   = 3
  container_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/api:latest"
  container_port  = 8080

  # Resource Allocation
  cpu    = 512
  memory = 1024

  # Networking
  vpc_id                     = module.vpc.vpc_id
  private_subnet_ids         = module.vpc.private_subnet_ids
  allowed_security_group_ids = [module.alb.security_group_id]

  # Load Balancer
  enable_load_balancer = true
  target_group_arn     = module.alb.default_target_group_arn

  # Auto Scaling
  enable_autoscaling = true
  min_capacity       = 2
  max_capacity       = 10
}

# Example 2: Cost-Optimized with Fargate Spot
module "ecs_service_spot" {
  source = "../"

  aws_region   = "us-east-1"
  environment  = "staging"
  project_name = "my-startup"

  cluster_name              = "staging-cluster"
  create_cluster            = true
  enable_container_insights = false # Cost optimization

  service_name  = "staging-api"
  desired_count = 2

  # Enable Fargate Spot for 70% cost savings
  enable_fargate_spot     = true
  fargate_spot_percentage = 70

  container_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/api:staging"
  container_port  = 8080

  cpu    = 256 # Smaller for staging
  memory = 512

  vpc_id                     = module.vpc.vpc_id
  private_subnet_ids         = module.vpc.private_subnet_ids
  allowed_security_group_ids = [module.alb.security_group_id]

  enable_load_balancer = true
  target_group_arn     = module.alb.default_target_group_arn

  # Minimal auto scaling
  enable_autoscaling = true
  min_capacity       = 1
  max_capacity       = 4

  # Reduced log retention
  log_retention_days = 7
}

# Example 3: Advanced with Secrets and Environment Variables
module "ecs_service_advanced" {
  source = "../"

  aws_region   = "us-east-1"
  environment  = "production"
  project_name = "my-startup"

  cluster_name   = "production-cluster"
  create_cluster = false # Use existing cluster

  service_name    = "backend-api"
  desired_count   = 5
  container_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/backend:v2.1.0"
  container_port  = 3000

  cpu    = 1024
  memory = 2048

  # Environment Variables
  environment_variables = {
    NODE_ENV       = "production"
    LOG_LEVEL      = "info"
    PORT           = "3000"
    REDIS_HOST     = "redis.internal.example.com"
    ENABLE_METRICS = "true"
  }

  # Secrets from AWS Secrets Manager
  secrets = [
    {
      name      = "DATABASE_URL"
      valueFrom = "arn:aws:secretsmanager:us-east-1:123456789012:secret:prod/database-url-AbCdEf"
    },
    {
      name      = "API_KEY"
      valueFrom = "arn:aws:secretsmanager:us-east-1:123456789012:secret:prod/api-key-XyZ123"
    },
    {
      name      = "JWT_SECRET"
      valueFrom = "arn:aws:ssm:us-east-1:123456789012:parameter/prod/jwt-secret"
    }
  ]

  # Custom container command
  command = ["node", "server.js", "--cluster"]

  # Networking
  vpc_id                     = module.vpc.vpc_id
  private_subnet_ids         = module.vpc.private_subnet_ids
  allowed_security_group_ids = [module.alb.security_group_id]

  enable_load_balancer              = true
  target_group_arn                  = module.alb.target_group_arns["api"]
  health_check_grace_period_seconds = 120

  # Auto Scaling with custom thresholds
  enable_autoscaling  = true
  min_capacity        = 3
  max_capacity        = 20
  cpu_target_value    = 60
  memory_target_value = 75
  scale_out_cooldown  = 30
  scale_in_cooldown   = 300

  # Enable ECS Exec for debugging
  enable_execute_command = true

  # Service Discovery
  enable_service_discovery       = true
  service_discovery_namespace_id = "ns-abc123xyz"

  tags = {
    Team       = "backend"
    CostCenter = "engineering"
    Compliance = "pci-dss"
  }
}

# Example 4: Internal Service (No Load Balancer)
module "ecs_service_worker" {
  source = "../"

  aws_region   = "us-east-1"
  environment  = "production"
  project_name = "my-startup"

  cluster_name   = "production-cluster"
  create_cluster = false

  service_name    = "background-worker"
  desired_count   = 2
  container_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/worker:latest"
  container_port  = 8080 # Not exposed externally

  cpu    = 512
  memory = 1024

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  # No load balancer for worker service
  enable_load_balancer = false

  # Service Discovery for internal communication
  enable_service_discovery       = true
  service_discovery_namespace_id = "ns-internal-services"

  # Auto scaling based on SQS queue depth (configured separately)
  enable_autoscaling = true
  min_capacity       = 1
  max_capacity       = 10

  tags = {
    ServiceType = "worker"
    Queue       = "main-processing-queue"
  }
}

# Outputs
output "api_service_arn" {
  description = "ARN of the API service"
  value       = module.ecs_service_basic.service_arn
}

output "api_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs_service_basic.cluster_name
}

output "task_role_arn" {
  description = "ARN of the task IAM role"
  value       = module.ecs_service_advanced.task_role_arn
}

output "security_group_id" {
  description = "Security group ID for ECS tasks"
  value       = module.ecs_service_basic.security_group_id
}

# Example: Create bootstrap resources for remote state
resource "aws_s3_bucket" "terraform_state" {
  bucket = "my-company-terraform-state"

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "shared"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-state-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform State Locks"
    Environment = "shared"
  }
}

