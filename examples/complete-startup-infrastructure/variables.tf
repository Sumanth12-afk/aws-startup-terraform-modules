# Complete Startup Infrastructure - Variables

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  
  validation {
    condition     = can(regex("^(dev|staging|production)$", var.environment))
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "project_name" {
  description = "Project name for resource naming and tagging"
  type        = string
}

# Networking
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "certificate_arn" {
  description = "ARN of ACM certificate for HTTPS"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = ""
}

# Compute
variable "backend_image" {
  description = "Docker image for backend API"
  type        = string
}

variable "frontend_image" {
  description = "Docker image for frontend web"
  type        = string
}

variable "enable_fargate_spot" {
  description = "Enable Fargate Spot for cost savings"
  type        = bool
  default     = false
}

# Database
variable "database_name" {
  description = "Name of the database"
  type        = string
  default     = "myapp"
}

variable "database_username" {
  description = "Master username for database"
  type        = string
  default     = "dbadmin"
}

# Monitoring
variable "alert_emails" {
  description = "Email addresses for CloudWatch alarms"
  type        = list(string)
  default     = []
}

