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

variable "enable_guardduty" {
  description = "Enable GuardDuty"
  type        = bool
  default     = true
}

variable "finding_publishing_frequency" {
  description = "Frequency for publishing findings (FIFTEEN_MINUTES, ONE_HOUR, SIX_HOURS)"
  type        = string
  default     = "FIFTEEN_MINUTES"
}

variable "enable_s3_protection" {
  description = "Enable S3 protection"
  type        = bool
  default     = true
}

variable "enable_kubernetes_protection" {
  description = "Enable Kubernetes protection"
  type        = bool
  default     = true
}

variable "enable_malware_protection" {
  description = "Enable malware protection"
  type        = bool
  default     = true
}

variable "enable_security_hub" {
  description = "Enable Security Hub"
  type        = bool
  default     = true
}

variable "enable_default_standards" {
  description = "Enable default Security Hub standards"
  type        = bool
  default     = true
}

variable "enable_config" {
  description = "Enable AWS Config"
  type        = bool
  default     = true
}

variable "config_recorder_name" {
  description = "AWS Config recorder name"
  type        = string
  default     = "default"
}

variable "config_delivery_channel_name" {
  description = "AWS Config delivery channel name"
  type        = string
  default     = "default"
}

variable "config_s3_bucket_name" {
  description = "S3 bucket for AWS Config"
  type        = string
  default     = ""
}

variable "include_global_resources" {
  description = "Include global resources in Config"
  type        = bool
  default     = true
}

variable "create_sns_topic" {
  description = "Create SNS topic for alerts"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

