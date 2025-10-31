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

# DynamoDB Table Configuration
variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_.-]+$", var.table_name))
    error_message = "Table name must contain only alphanumeric characters, underscores, dots, and hyphens."
  }
}

variable "billing_mode" {
  description = "Billing mode (PROVISIONED or PAY_PER_REQUEST)"
  type        = string
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = can(regex("^(PROVISIONED|PAY_PER_REQUEST)$", var.billing_mode))
    error_message = "Billing mode must be PROVISIONED or PAY_PER_REQUEST."
  }
}

variable "read_capacity" {
  description = "Read capacity units (only for PROVISIONED mode)"
  type        = number
  default     = 5
}

variable "write_capacity" {
  description = "Write capacity units (only for PROVISIONED mode)"
  type        = number
  default     = 5
}

# Schema Configuration
variable "hash_key" {
  description = "Partition key attribute name"
  type        = string
}

variable "hash_key_type" {
  description = "Partition key attribute type (S, N, or B)"
  type        = string
  default     = "S"

  validation {
    condition     = can(regex("^(S|N|B)$", var.hash_key_type))
    error_message = "Hash key type must be S (string), N (number), or B (binary)."
  }
}

variable "range_key" {
  description = "Sort key attribute name (optional)"
  type        = string
  default     = null
}

variable "range_key_type" {
  description = "Sort key attribute type (S, N, or B)"
  type        = string
  default     = "S"

  validation {
    condition     = can(regex("^(S|N|B)$", var.range_key_type))
    error_message = "Range key type must be S (string), N (number), or B (binary)."
  }
}

variable "attributes" {
  description = "Additional attributes for GSI/LSI"
  type = list(object({
    name = string
    type = string
  }))
  default = []
}

# Global Secondary Indexes
variable "global_secondary_indexes" {
  description = "List of global secondary indexes"
  type = list(object({
    name               = string
    hash_key           = string
    range_key          = optional(string)
    projection_type    = string
    non_key_attributes = optional(list(string))
    read_capacity      = optional(number)
    write_capacity     = optional(number)
  }))
  default = []
}

# Local Secondary Indexes
variable "local_secondary_indexes" {
  description = "List of local secondary indexes"
  type = list(object({
    name               = string
    range_key          = string
    projection_type    = string
    non_key_attributes = optional(list(string))
  }))
  default = []
}

# Time To Live
variable "enable_ttl" {
  description = "Enable Time To Live"
  type        = bool
  default     = false
}

variable "ttl_attribute_name" {
  description = "Name of the TTL attribute"
  type        = string
  default     = "ttl"
}

# Point-in-Time Recovery
variable "enable_point_in_time_recovery" {
  description = "Enable point-in-time recovery"
  type        = bool
  default     = true
}

# Encryption
variable "enable_encryption" {
  description = "Enable server-side encryption"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption (uses AWS-managed key if not provided)"
  type        = string
  default     = null
}

# Streams
variable "enable_streams" {
  description = "Enable DynamoDB streams"
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "Stream view type (KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES)"
  type        = string
  default     = "NEW_AND_OLD_IMAGES"

  validation {
    condition     = can(regex("^(KEYS_ONLY|NEW_IMAGE|OLD_IMAGE|NEW_AND_OLD_IMAGES)$", var.stream_view_type))
    error_message = "Stream view type must be KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, or NEW_AND_OLD_IMAGES."
  }
}

# Auto Scaling
variable "enable_autoscaling" {
  description = "Enable auto-scaling for provisioned capacity"
  type        = bool
  default     = false
}

variable "autoscaling_read_target" {
  description = "Target utilization percentage for read capacity"
  type        = number
  default     = 70
}

variable "autoscaling_read_min_capacity" {
  description = "Minimum read capacity for auto-scaling"
  type        = number
  default     = 5
}

variable "autoscaling_read_max_capacity" {
  description = "Maximum read capacity for auto-scaling"
  type        = number
  default     = 100
}

variable "autoscaling_write_target" {
  description = "Target utilization percentage for write capacity"
  type        = number
  default     = 70
}

variable "autoscaling_write_min_capacity" {
  description = "Minimum write capacity for auto-scaling"
  type        = number
  default     = 5
}

variable "autoscaling_write_max_capacity" {
  description = "Maximum write capacity for auto-scaling"
  type        = number
  default     = 100
}

# Deletion Protection
variable "deletion_protection_enabled" {
  description = "Enable deletion protection"
  type        = bool
  default     = true
}

# Table Class
variable "table_class" {
  description = "Table class (STANDARD or STANDARD_INFREQUENT_ACCESS)"
  type        = string
  default     = "STANDARD"

  validation {
    condition     = can(regex("^(STANDARD|STANDARD_INFREQUENT_ACCESS)$", var.table_class))
    error_message = "Table class must be STANDARD or STANDARD_INFREQUENT_ACCESS."
  }
}

# Replica Configuration (Global Tables)
variable "replica_regions" {
  description = "List of regions for global table replicas"
  type        = list(string)
  default     = []
}

# Tags
variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}

