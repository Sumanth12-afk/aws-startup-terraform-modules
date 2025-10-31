# ECS Fargate Service Module - Input Variables

# ========================================
# Remote State & AWS Configuration
# ========================================

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "S3 bucket name for Terraform state (used for backend configuration)"
  type        = string
  default     = ""
}

variable "state_lock_table" {
  description = "DynamoDB table name for Terraform state locking"
  type        = string
  default     = "terraform-state-locks"
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string

  validation {
    condition     = can(regex("^(dev|staging|production|prod)$", var.environment))
    error_message = "Environment must be dev, staging, or production/prod."
  }
}

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
  default     = "my-project"
}

# ========================================
# ECS Cluster Configuration
# ========================================

variable "cluster_name" {
  description = "Name of the ECS cluster (will be created if it doesn't exist)"
  type        = string
}

variable "create_cluster" {
  description = "Whether to create a new ECS cluster or use existing"
  type        = bool
  default     = true
}

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights for the cluster"
  type        = bool
  default     = true
}

# ========================================
# ECS Service Configuration
# ========================================

variable "service_name" {
  description = "Name of the ECS service"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.service_name))
    error_message = "Service name must contain only alphanumeric characters and hyphens."
  }
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 2

  validation {
    condition     = var.desired_count >= 0
    error_message = "Desired count must be non-negative."
  }
}

variable "enable_fargate_spot" {
  description = "Enable Fargate Spot capacity provider for cost savings"
  type        = bool
  default     = false
}

variable "fargate_spot_percentage" {
  description = "Percentage of tasks to run on Fargate Spot (0-100)"
  type        = number
  default     = 50

  validation {
    condition     = var.fargate_spot_percentage >= 0 && var.fargate_spot_percentage <= 100
    error_message = "Fargate Spot percentage must be between 0 and 100."
  }
}

variable "enable_execute_command" {
  description = "Enable ECS Exec for debugging (SSH into containers)"
  type        = bool
  default     = false
}

variable "enable_service_discovery" {
  description = "Enable AWS Cloud Map service discovery"
  type        = bool
  default     = false
}

variable "service_discovery_namespace_id" {
  description = "Cloud Map namespace ID for service discovery"
  type        = string
  default     = ""
}

# ========================================
# Task Definition Configuration
# ========================================

variable "container_name" {
  description = "Name of the container"
  type        = string
  default     = ""
}

variable "container_image" {
  description = "Docker image URL (ECR or Docker Hub)"
  type        = string
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 80
}

variable "host_port" {
  description = "Host port to map to container port (0 for dynamic port mapping)"
  type        = number
  default     = 0
}

variable "cpu" {
  description = "CPU units for the task (256, 512, 1024, 2048, 4096)"
  type        = number
  default     = 512

  validation {
    condition     = contains([256, 512, 1024, 2048, 4096], var.cpu)
    error_message = "CPU must be one of: 256, 512, 1024, 2048, 4096."
  }
}

variable "memory" {
  description = "Memory in MB for the task"
  type        = number
  default     = 1024

  validation {
    condition     = var.memory >= 512 && var.memory <= 30720
    error_message = "Memory must be between 512 and 30720 MB."
  }
}

variable "task_role_arn" {
  description = "IAM role ARN for task (application permissions)"
  type        = string
  default     = ""
}

variable "execution_role_arn" {
  description = "IAM role ARN for task execution (ECS agent permissions)"
  type        = string
  default     = ""
}

variable "environment_variables" {
  description = "Environment variables for the container"
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Secrets from Secrets Manager or SSM Parameter Store"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

variable "command" {
  description = "Command to run in the container (overrides Docker CMD)"
  type        = list(string)
  default     = null
}

variable "entrypoint" {
  description = "Entrypoint for the container (overrides Docker ENTRYPOINT)"
  type        = list(string)
  default     = null
}

# ========================================
# Networking Configuration
# ========================================

variable "vpc_id" {
  description = "VPC ID where ECS tasks will run"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "At least 2 private subnets required for high availability."
  }
}

variable "security_group_ids" {
  description = "Additional security group IDs to attach to tasks"
  type        = list(string)
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the service"
  type        = list(string)
  default     = []
}

variable "allowed_security_group_ids" {
  description = "Security group IDs allowed to access the service"
  type        = list(string)
  default     = []
}

# ========================================
# Load Balancer Configuration
# ========================================

variable "enable_load_balancer" {
  description = "Attach service to a load balancer target group"
  type        = bool
  default     = true
}

variable "target_group_arn" {
  description = "ARN of the target group to attach the service to"
  type        = string
  default     = ""
}

variable "health_check_grace_period_seconds" {
  description = "Seconds to ignore failing load balancer health checks on startup"
  type        = number
  default     = 60
}

# ========================================
# Auto Scaling Configuration
# ========================================

variable "enable_autoscaling" {
  description = "Enable auto scaling for the ECS service"
  type        = bool
  default     = true
}

variable "min_capacity" {
  description = "Minimum number of tasks"
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Maximum number of tasks"
  type        = number
  default     = 10
}

variable "cpu_target_value" {
  description = "Target CPU utilization percentage for auto scaling"
  type        = number
  default     = 70

  validation {
    condition     = var.cpu_target_value > 0 && var.cpu_target_value <= 100
    error_message = "CPU target must be between 0 and 100."
  }
}

variable "memory_target_value" {
  description = "Target memory utilization percentage for auto scaling"
  type        = number
  default     = 80

  validation {
    condition     = var.memory_target_value > 0 && var.memory_target_value <= 100
    error_message = "Memory target must be between 0 and 100."
  }
}

variable "scale_in_cooldown" {
  description = "Cooldown period (seconds) after scale-in activity"
  type        = number
  default     = 300
}

variable "scale_out_cooldown" {
  description = "Cooldown period (seconds) after scale-out activity"
  type        = number
  default     = 60
}

# ========================================
# Logging Configuration
# ========================================

variable "enable_logging" {
  description = "Enable CloudWatch Logs for containers"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention period in days"
  type        = number
  default     = 30

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Invalid log retention days value."
  }
}

# ========================================
# Tags
# ========================================

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}

