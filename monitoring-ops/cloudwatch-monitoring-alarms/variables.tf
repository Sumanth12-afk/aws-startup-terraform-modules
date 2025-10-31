variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile"
  type        = string
  default     = "default"
}

variable "alarm_topic_name" {
  description = "SNS topic name for alarms"
  type        = string
  default     = "monitoring-alarms"
}

variable "email_endpoints" {
  description = "Email addresses for alarm notifications"
  type        = list(string)
  default     = []
}

variable "enable_ec2_alarms" {
  description = "Enable EC2 alarms"
  type        = bool
  default     = false
}

variable "ec2_instance_ids" {
  description = "EC2 instance IDs to monitor"
  type        = list(string)
  default     = []
}

variable "ec2_cpu_threshold" {
  description = "CPU threshold for EC2 alarms"
  type        = number
  default     = 80
}

variable "enable_rds_alarms" {
  description = "Enable RDS alarms"
  type        = bool
  default     = false
}

variable "rds_instance_ids" {
  description = "RDS instance IDs to monitor"
  type        = list(string)
  default     = []
}

variable "rds_cpu_threshold" {
  description = "CPU threshold for RDS alarms"
  type        = number
  default     = 80
}

variable "enable_alb_alarms" {
  description = "Enable ALB alarms"
  type        = bool
  default     = false
}

variable "alb_target_group_arns" {
  description = "ALB target group ARNs to monitor"
  type        = list(string)
  default     = []
}

variable "alb_names" {
  description = "ALB names"
  type        = list(string)
  default     = []
}

variable "alb_response_time_threshold" {
  description = "Response time threshold for ALB"
  type        = number
  default     = 1
}

variable "create_dashboard" {
  description = "Create CloudWatch dashboard"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

