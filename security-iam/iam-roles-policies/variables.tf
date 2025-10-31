# Environment Configuration
variable "environment" {
  description = "Environment name (e.g., dev, staging, production)"
  type        = string

  validation {
    condition     = can(regex("^(dev|staging|production|test)$", var.environment))
    error_message = "Environment must be dev, staging, production, or test."
  }
}

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "default"
}

# Remote State Configuration
variable "state_bucket_name" {
  description = "S3 bucket name for Terraform remote state"
  type        = string
  default     = ""
}

variable "state_lock_table" {
  description = "DynamoDB table name for Terraform state locking"
  type        = string
  default     = ""
}

# IAM Role Configuration
variable "role_name" {
  description = "Name of the IAM role"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_+=,.@-]{1,64}$", var.role_name))
    error_message = "Role name must be 1-64 characters and contain only alphanumeric characters and +=,.@-_"
  }
}

variable "role_description" {
  description = "Description of the IAM role"
  type        = string
  default     = null
}

variable "max_session_duration" {
  description = "Maximum session duration in seconds (3600-43200)"
  type        = number
  default     = 3600

  validation {
    condition     = var.max_session_duration >= 3600 && var.max_session_duration <= 43200
    error_message = "Max session duration must be between 3600 and 43200 seconds."
  }
}

# Trust Relationships
variable "trusted_services" {
  description = "AWS services that can assume this role"
  type        = list(string)
  default     = []
}

variable "trusted_role_arns" {
  description = "IAM role ARNs that can assume this role"
  type        = list(string)
  default     = []
}

variable "trusted_account_ids" {
  description = "AWS account IDs that can assume this role"
  type        = list(string)
  default     = []
}

variable "require_mfa" {
  description = "Require MFA for assuming this role"
  type        = bool
  default     = false
}

# Policies
variable "policy_arns" {
  description = "List of IAM policy ARNs to attach to the role"
  type        = list(string)
  default     = []
}

variable "inline_policies" {
  description = "Map of inline policy names to policy documents (JSON)"
  type        = map(string)
  default     = {}
}

variable "create_instance_profile" {
  description = "Create an instance profile for EC2"
  type        = bool
  default     = false
}

# Permissions Boundary
variable "permissions_boundary" {
  description = "ARN of the policy to set as permissions boundary"
  type        = string
  default     = null
}

# Path
variable "path" {
  description = "Path for the IAM role"
  type        = string
  default     = "/"
}

# Tags
variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}

