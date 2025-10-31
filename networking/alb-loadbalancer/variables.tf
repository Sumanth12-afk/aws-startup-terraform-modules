# Application Load Balancer Module - Input Variables

# Required Variables
variable "name" {
  description = "Name of the Application Load Balancer"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.name))
    error_message = "Name must contain only alphanumeric characters and hyphens."
  }
}

variable "vpc_id" {
  description = "ID of the VPC where ALB will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ALB (minimum 2 in different AZs)"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least 2 subnets in different AZs are required for high availability."
  }
}

# Environment
variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "production"

  validation {
    condition     = can(regex("^(dev|staging|production|prod)$", var.environment))
    error_message = "Environment must be dev, staging, or production/prod."
  }
}

# ALB Configuration
variable "internal" {
  description = "Whether the load balancer is internal or internet-facing"
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for the load balancer"
  type        = bool
  default     = true
}

variable "enable_cross_zone_load_balancing" {
  description = "Enable cross-zone load balancing"
  type        = bool
  default     = true
}

variable "enable_http2" {
  description = "Enable HTTP/2"
  type        = bool
  default     = true
}

variable "enable_waf_fail_open" {
  description = "Enable WAF fail open mode"
  type        = bool
  default     = false
}

variable "drop_invalid_header_fields" {
  description = "Drop invalid HTTP header fields"
  type        = bool
  default     = true
}

variable "idle_timeout" {
  description = "Time in seconds that the connection is allowed to be idle"
  type        = number
  default     = 60

  validation {
    condition     = var.idle_timeout >= 1 && var.idle_timeout <= 4000
    error_message = "Idle timeout must be between 1 and 4000 seconds."
  }
}

# Security
variable "additional_security_groups" {
  description = "Additional security group IDs to attach to ALB"
  type        = list(string)
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the ALB"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# HTTP/HTTPS Configuration
variable "enable_http" {
  description = "Enable HTTP listener (port 80)"
  type        = bool
  default     = true
}

variable "enable_https" {
  description = "Enable HTTPS listener (port 443)"
  type        = bool
  default     = true
}

variable "http_redirect_to_https" {
  description = "Redirect HTTP to HTTPS automatically"
  type        = bool
  default     = true
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate for HTTPS listener"
  type        = string
  default     = ""
}

variable "additional_certificates" {
  description = "List of additional SSL certificate ARNs for SNI"
  type        = list(string)
  default     = []
}

variable "ssl_policy" {
  description = "SSL policy for HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  validation {
    condition     = can(regex("^ELBSecurityPolicy-", var.ssl_policy))
    error_message = "SSL policy must be a valid AWS ELB security policy."
  }
}

# Target Groups
variable "target_groups" {
  description = "Map of target group configurations"
  type = map(object({
    port                 = number
    protocol             = string
    target_type          = string
    deregistration_delay = number
    health_check = object({
      enabled             = bool
      healthy_threshold   = number
      unhealthy_threshold = number
      timeout             = number
      interval            = number
      path                = string
      port                = string
      protocol            = string
      matcher             = string
    })
    stickiness_enabled  = bool
    stickiness_duration = number
  }))
  default = {
    default = {
      port                 = 80
      protocol             = "HTTP"
      target_type          = "instance"
      deregistration_delay = 300
      health_check = {
        enabled             = true
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 5
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        matcher             = "200-299"
      }
      stickiness_enabled  = false
      stickiness_duration = 86400
    }
  }
}

variable "default_target_group" {
  description = "Name of the default target group"
  type        = string
  default     = "default"
}

# Listener Rules
variable "listener_rules" {
  description = "Map of listener rule configurations for path-based routing"
  type = map(object({
    priority      = number
    target_group  = string
    path_patterns = list(string)
    host_headers  = list(string)
  }))
  default = {}
}

# Access Logs
variable "enable_access_logs" {
  description = "Enable access logs to S3"
  type        = bool
  default     = false
}

variable "access_logs_bucket" {
  description = "S3 bucket name for access logs"
  type        = string
  default     = ""
}

variable "access_logs_prefix" {
  description = "S3 bucket prefix for access logs"
  type        = string
  default     = ""
}

# CloudWatch Alarms
variable "enable_cloudwatch_alarms" {
  description = "Enable CloudWatch alarms for ALB monitoring"
  type        = bool
  default     = false
}

variable "alarm_actions" {
  description = "List of ARNs to notify when alarm triggers"
  type        = list(string)
  default     = []
}

variable "target_response_time_threshold" {
  description = "Threshold for target response time alarm (seconds)"
  type        = number
  default     = 1.0
}

variable "unhealthy_host_threshold" {
  description = "Threshold for unhealthy host count alarm"
  type        = number
  default     = 1
}

variable "elb_5xx_threshold" {
  description = "Threshold for ELB 5XX error count alarm"
  type        = number
  default     = 10
}

# Tags
variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}

