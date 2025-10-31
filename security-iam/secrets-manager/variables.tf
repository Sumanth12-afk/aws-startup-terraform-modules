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

variable "secret_name" {
  description = "Name of the secret"
  type        = string
}

variable "description" {
  description = "Description of the secret"
  type        = string
  default     = null
}

variable "secret_string" {
  description = "Secret value as string (JSON for key-value pairs)"
  type        = string
  default     = null
  sensitive   = true
}

variable "secret_binary" {
  description = "Secret value as binary"
  type        = string
  default     = null
  sensitive   = true
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
  default     = null
}

variable "recovery_window_in_days" {
  description = "Recovery window in days (0 for immediate deletion)"
  type        = number
  default     = 30
}

variable "enable_rotation" {
  description = "Enable automatic rotation"
  type        = bool
  default     = false
}

variable "rotation_lambda_arn" {
  description = "Lambda ARN for rotation"
  type        = string
  default     = null
}

variable "rotation_days" {
  description = "Days between rotations"
  type        = number
  default     = 30
}

variable "secret_policy" {
  description = "Resource policy for the secret"
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

