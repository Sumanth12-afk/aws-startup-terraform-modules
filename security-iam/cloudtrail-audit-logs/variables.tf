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

variable "trail_name" {
  description = "Name of the CloudTrail trail"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name for CloudTrail logs"
  type        = string
}

variable "include_global_service_events" {
  description = "Include global service events"
  type        = bool
  default     = true
}

variable "is_multi_region_trail" {
  description = "Enable multi-region trail"
  type        = bool
  default     = true
}

variable "enable_log_file_validation" {
  description = "Enable log file validation"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
  default     = null
}

variable "enable_cloudwatch_logs" {
  description = "Enable CloudWatch Logs integration"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention in days"
  type        = number
  default     = 90
}

variable "event_selectors" {
  description = "Event selectors for the trail"
  type = list(object({
    read_write_type           = string
    include_management_events = bool
    data_resources = list(object({
      type   = string
      values = list(string)
    }))
  }))
  default = []
}

variable "transition_to_ia_days" {
  description = "Days until logs transition to IA"
  type        = number
  default     = 90
}

variable "transition_to_glacier_days" {
  description = "Days until logs transition to Glacier"
  type        = number
  default     = 180
}

variable "expiration_days" {
  description = "Days until logs expire"
  type        = number
  default     = 2555 # 7 years for compliance
}

variable "force_destroy" {
  description = "Allow bucket destruction with objects"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

