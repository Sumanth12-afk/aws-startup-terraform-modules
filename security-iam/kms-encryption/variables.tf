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

variable "key_alias" {
  description = "KMS key alias (without 'alias/' prefix)"
  type        = string
}

variable "description" {
  description = "KMS key description"
  type        = string
  default     = "KMS key for encryption"
}

variable "deletion_window_in_days" {
  description = "Deletion window in days (7-30)"
  type        = number
  default     = 30
}

variable "enable_key_rotation" {
  description = "Enable automatic key rotation"
  type        = bool
  default     = true
}

variable "multi_region" {
  description = "Enable multi-region key"
  type        = bool
  default     = false
}

variable "key_usage" {
  description = "Key usage (ENCRYPT_DECRYPT or SIGN_VERIFY)"
  type        = string
  default     = "ENCRYPT_DECRYPT"
}

variable "customer_master_key_spec" {
  description = "Key spec"
  type        = string
  default     = "SYMMETRIC_DEFAULT"
}

variable "key_administrators" {
  description = "IAM ARNs for key administrators"
  type        = list(string)
  default     = []
}

variable "key_users" {
  description = "IAM ARNs for key users"
  type        = list(string)
  default     = []
}

variable "key_grant_users" {
  description = "IAM ARNs for grant users"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

