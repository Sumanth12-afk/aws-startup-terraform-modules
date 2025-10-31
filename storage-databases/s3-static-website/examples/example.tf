# Example usage of the S3 Static Website module

# Basic Static Website
module "simple_website" {
  source = "../"

  environment = "production"
  aws_region  = "us-east-1"

  bucket_name          = "my-simple-website-2024"
  enable_public_access = true
  enable_versioning    = true

  tags = {
    Project = "MyWebsite"
    Owner   = "WebTeam"
  }
}

# Production Website with CloudFront
module "production_website" {
  source = "../"

  # Environment
  environment = "production"
  aws_region  = "us-east-1"

  # Remote State
  state_bucket_name = "my-terraform-state"
  state_lock_table  = "terraform-locks"

  # Bucket Configuration
  bucket_name   = "my-production-website-2024"
  force_destroy = false

  # CloudFront Configuration
  enable_cloudfront      = true
  cloudfront_price_class = "PriceClass_100"
  custom_domain          = "www.example.com"
  acm_certificate_arn    = "arn:aws:acm:us-east-1:123456789012:certificate/abc123"

  # Security
  enable_encryption     = true
  kms_key_id            = "arn:aws:kms:us-east-1:123456789012:key/abc123"
  enable_public_access  = false  # Served via CloudFront only

  # Versioning & Lifecycle
  enable_versioning                  = true
  enable_lifecycle_rules             = true
  noncurrent_version_expiration_days = 30
  transition_to_ia_days              = 30
  transition_to_glacier_days         = 90

  # Logging
  enable_access_logging = true

  # Monitoring
  enable_metrics = true

  # CORS for API access
  enable_cors          = true
  cors_allowed_origins = ["https://www.example.com", "https://app.example.com"]
  cors_allowed_methods = ["GET", "HEAD"]

  tags = {
    Project     = "MyWebsite"
    Environment = "production"
    Owner       = "WebTeam"
    CostCenter  = "Marketing"
  }
}

# SPA (Single Page Application) with Custom Routing
module "spa_website" {
  source = "../"

  environment = "production"
  aws_region  = "us-east-1"

  bucket_name          = "my-spa-website-2024"
  enable_cloudfront    = true
  enable_public_access = false

  # SPA routing - redirect all 404s to index.html
  routing_rules = jsonencode([{
    condition = {
      http_error_code_returned_equals = "404"
    }
    redirect = {
      replace_key_with = "index.html"
    }
  }])

  # CORS for API calls
  enable_cors          = true
  cors_allowed_origins = ["https://api.example.com"]
  cors_allowed_methods = ["GET", "HEAD", "POST", "PUT", "DELETE"]
  cors_allowed_headers = ["*"]

  tags = {
    Project = "MySPA"
    Type    = "SinglePageApp"
  }
}

# Outputs
output "simple_website_url" {
  value = module.simple_website.website_endpoint
}

output "production_website_url" {
  value = module.production_website.deployment_url
}

output "production_sync_command" {
  value = module.production_website.s3_sync_command
}

output "production_invalidation_command" {
  value = module.production_website.cloudfront_invalidation_command
}

