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

variable "parameters" {
  description = "SSM parameters to create"
  type = map(object({
    description = string
    type        = string
    value       = string
    tier        = string
  }))
  default = {}
}

variable "kms_key_id" {
  description = "KMS key ID for SecureString parameters"
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

