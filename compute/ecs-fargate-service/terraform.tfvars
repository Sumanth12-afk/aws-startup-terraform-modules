# Example Terraform Variables for ECS Fargate Service
# Copy this file and customize for your environment

# ========================================
# Remote State & AWS Configuration
# ========================================

aws_region        = "us-east-1"
state_bucket_name = "my-company-terraform-state"
state_lock_table  = "terraform-state-locks"
environment       = "production"
project_name      = "my-startup"

# ========================================
# ECS Cluster Configuration
# ========================================

cluster_name              = "production-cluster"
create_cluster            = true
enable_container_insights = true

# ========================================
# ECS Service Configuration
# ========================================

service_name            = "api-service"
desired_count           = 3
enable_fargate_spot     = true
fargate_spot_percentage = 50

# Enable for debugging (SSH into containers)
enable_execute_command = false

# Service Discovery (optional)
enable_service_discovery       = false
service_discovery_namespace_id = ""

# ========================================
# Task Definition Configuration
# ========================================

container_name  = "api"
container_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/api:latest"
container_port  = 8080
host_port       = 0 # Dynamic port mapping

# Resource allocation
cpu    = 512  # 0.5 vCPU
memory = 1024 # 1 GB

# Environment variables
environment_variables = {
  NODE_ENV  = "production"
  LOG_LEVEL = "info"
  PORT      = "8080"
}

# Secrets from AWS Secrets Manager or SSM Parameter Store
secrets = [
  # {
  #   name      = "DATABASE_URL"
  #   valueFrom = "arn:aws:secretsmanager:us-east-1:123456789012:secret:prod/db-url-AbCdEf"
  # },
  # {
  #   name      = "API_KEY"
  #   valueFrom = "arn:aws:ssm:us-east-1:123456789012:parameter/prod/api-key"
  # }
]

# ========================================
# Networking Configuration
# ========================================

vpc_id             = "vpc-12345678"
private_subnet_ids = ["subnet-abc123", "subnet-def456", "subnet-ghi789"]

# Allow access from ALB security group
allowed_security_group_ids = ["sg-alb123456"]

# ========================================
# Load Balancer Configuration
# ========================================

enable_load_balancer              = true
target_group_arn                  = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/api-tg/1234567890abcdef"
health_check_grace_period_seconds = 60

# ========================================
# Auto Scaling Configuration
# ========================================

enable_autoscaling  = true
min_capacity        = 2
max_capacity        = 10
cpu_target_value    = 70
memory_target_value = 80
scale_in_cooldown   = 300
scale_out_cooldown  = 60

# ========================================
# Logging Configuration
# ========================================

enable_logging     = true
log_retention_days = 30

# ========================================
# Tags
# ========================================

tags = {
  Team        = "platform"
  CostCenter  = "engineering"
  Application = "api"
}

