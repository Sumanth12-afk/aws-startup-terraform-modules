# Environment Configuration
environment = "production"
aws_region  = "us-east-1"
aws_profile = "default"

# Remote State Configuration (uncomment and configure for production)
# state_bucket_name = "my-terraform-state-bucket"
# state_lock_table  = "terraform-state-lock"

# S3 Bucket Configuration
bucket_name   = "my-static-website-prod"
force_destroy = false

# Website Configuration
index_document = "index.html"
error_document = "error.html"

# Access Configuration
enable_public_access = true
enable_cloudfront    = false

# Optional: Enable CloudFront for better performance
# enable_cloudfront      = true
# cloudfront_price_class = "PriceClass_100"
# custom_domain          = "www.example.com"
# acm_certificate_arn    = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"

# Versioning & Lifecycle
enable_versioning                  = true
enable_lifecycle_rules             = true
noncurrent_version_expiration_days = 90
transition_to_ia_days              = 30
transition_to_glacier_days         = 90

# Logging Configuration
enable_access_logging = true
access_log_prefix     = "access-logs/"

# Security Configuration
enable_encryption = true
# kms_key_id        = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"

# CORS Configuration (enable for API access)
enable_cors          = false
cors_allowed_origins = ["*"]
cors_allowed_methods = ["GET", "HEAD"]
cors_allowed_headers = ["*"]
cors_max_age_seconds = 3000

# Content Management
cache_control = "public, max-age=31536000"

# Monitoring
enable_metrics      = true
enable_inventory    = false
inventory_frequency = "Weekly"

# Tags
tags = {
  Project     = "MyWebsite"
  Owner       = "DevOps Team"
  CostCenter  = "Marketing"
  Environment = "production"
}

