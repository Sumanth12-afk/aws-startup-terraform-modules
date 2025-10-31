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

# S3 Bucket Configuration
variable "bucket_name" {
  description = "Name of the S3 bucket (must be globally unique)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "Bucket name must be 3-63 characters, lowercase alphanumeric and hyphens only."
  }
}

variable "bucket_prefix" {
  description = "Prefix for bucket name (auto-generates unique name if bucket_name not provided)"
  type        = string
  default     = ""
}

variable "force_destroy" {
  description = "Allow bucket to be destroyed even if it contains objects"
  type        = bool
  default     = false
}

# Website Configuration
variable "index_document" {
  description = "Name of the index document"
  type        = string
  default     = "index.html"
}

variable "error_document" {
  description = "Name of the error document"
  type        = string
  default     = "error.html"
}

variable "routing_rules" {
  description = "JSON array containing routing rules"
  type        = string
  default     = null
}

# Access Configuration
variable "enable_public_access" {
  description = "Enable public read access to bucket objects"
  type        = bool
  default     = true
}

variable "enable_cloudfront" {
  description = "Enable CloudFront distribution for the website"
  type        = bool
  default     = false
}

variable "cloudfront_price_class" {
  description = "CloudFront price class (PriceClass_All, PriceClass_200, PriceClass_100)"
  type        = string
  default     = "PriceClass_100"

  validation {
    condition     = can(regex("^PriceClass_(All|200|100)$", var.cloudfront_price_class))
    error_message = "Price class must be PriceClass_All, PriceClass_200, or PriceClass_100."
  }
}

variable "custom_domain" {
  description = "Custom domain name for the website"
  type        = string
  default     = null
}

variable "acm_certificate_arn" {
  description = "ARN of ACM certificate for custom domain (must be in us-east-1 for CloudFront)"
  type        = string
  default     = null
}

# Versioning & Lifecycle
variable "enable_versioning" {
  description = "Enable S3 versioning"
  type        = bool
  default     = true
}

variable "enable_lifecycle_rules" {
  description = "Enable lifecycle management rules"
  type        = bool
  default     = true
}

variable "noncurrent_version_expiration_days" {
  description = "Days until noncurrent versions expire"
  type        = number
  default     = 90
}

variable "transition_to_ia_days" {
  description = "Days until objects transition to Infrequent Access"
  type        = number
  default     = 30
}

variable "transition_to_glacier_days" {
  description = "Days until objects transition to Glacier"
  type        = number
  default     = 90
}

# Logging Configuration
variable "enable_access_logging" {
  description = "Enable S3 access logging"
  type        = bool
  default     = true
}

variable "access_log_bucket" {
  description = "Bucket name for access logs (creates new bucket if not provided)"
  type        = string
  default     = null
}

variable "access_log_prefix" {
  description = "Prefix for access log objects"
  type        = string
  default     = "access-logs/"
}

# Security Configuration
variable "enable_encryption" {
  description = "Enable server-side encryption"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ID for server-side encryption (uses S3-managed keys if not provided)"
  type        = string
  default     = null
}

variable "enable_cors" {
  description = "Enable CORS configuration"
  type        = bool
  default     = false
}

variable "cors_allowed_origins" {
  description = "Allowed origins for CORS"
  type        = list(string)
  default     = ["*"]
}

variable "cors_allowed_methods" {
  description = "Allowed methods for CORS"
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "cors_allowed_headers" {
  description = "Allowed headers for CORS"
  type        = list(string)
  default     = ["*"]
}

variable "cors_max_age_seconds" {
  description = "Max age in seconds for CORS preflight requests"
  type        = number
  default     = 3000
}

# Content Management
variable "content_types" {
  description = "Map of file extensions to content types"
  type        = map(string)
  default = {
    "html"  = "text/html"
    "css"   = "text/css"
    "js"    = "application/javascript"
    "json"  = "application/json"
    "png"   = "image/png"
    "jpg"   = "image/jpeg"
    "jpeg"  = "image/jpeg"
    "gif"   = "image/gif"
    "svg"   = "image/svg+xml"
    "ico"   = "image/x-icon"
    "woff"  = "font/woff"
    "woff2" = "font/woff2"
    "ttf"   = "font/ttf"
    "eot"   = "application/vnd.ms-fontobject"
  }
}

variable "cache_control" {
  description = "Default cache control header value"
  type        = string
  default     = "public, max-age=31536000"
}

# Monitoring
variable "enable_metrics" {
  description = "Enable S3 request metrics"
  type        = bool
  default     = true
}

variable "enable_inventory" {
  description = "Enable S3 inventory"
  type        = bool
  default     = false
}

variable "inventory_frequency" {
  description = "Inventory frequency (Daily or Weekly)"
  type        = string
  default     = "Weekly"

  validation {
    condition     = can(regex("^(Daily|Weekly)$", var.inventory_frequency))
    error_message = "Inventory frequency must be Daily or Weekly."
  }
}

# Tags
variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}

