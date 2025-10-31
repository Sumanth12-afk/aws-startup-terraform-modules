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

variable "monthly_budget_limit" {
  description = "Monthly budget limit in USD"
  type        = string
}

variable "notification_thresholds" {
  description = "Budget notification thresholds in percentage"
  type        = list(number)
  default     = [50, 80, 100]
}

variable "email_addresses" {
  description = "Email addresses for budget alerts"
  type        = list(string)
}

variable "enable_anomaly_detection" {
  description = "Enable cost anomaly detection"
  type        = bool
  default     = true
}

variable "anomaly_threshold" {
  description = "Anomaly detection threshold in USD"
  type        = number
  default     = 100
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

