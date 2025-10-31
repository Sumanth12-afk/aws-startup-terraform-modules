# Data Sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Generate unique bucket name if not provided
resource "random_id" "bucket_suffix" {
  count       = var.bucket_name == "" ? 1 : 0
  byte_length = 4
}

locals {
  bucket_name     = var.bucket_name != "" ? var.bucket_name : "${var.bucket_prefix}-${var.environment}-${random_id.bucket_suffix[0].hex}"
  log_bucket_name = var.access_log_bucket != null ? var.access_log_bucket : "${local.bucket_name}-logs"

  common_tags = merge(
    var.tags,
    {
      Name        = local.bucket_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Module      = "s3-static-website"
    }
  )
}

#---------------------------------------------------------------
# S3 Bucket for Access Logs
#---------------------------------------------------------------

resource "aws_s3_bucket" "access_logs" {
  count         = var.enable_access_logging ? 1 : 0
  bucket        = local.log_bucket_name
  force_destroy = var.force_destroy

  tags = merge(
    local.common_tags,
    {
      Purpose = "AccessLogs"
    }
  )
}

resource "aws_s3_bucket_ownership_controls" "access_logs" {
  count  = var.enable_access_logging ? 1 : 0
  bucket = aws_s3_bucket.access_logs[0].id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "access_logs" {
  count      = var.enable_access_logging ? 1 : 0
  bucket     = aws_s3_bucket.access_logs[0].id
  acl        = "log-delivery-write"
  depends_on = [aws_s3_bucket_ownership_controls.access_logs]
}

resource "aws_s3_bucket_public_access_block" "access_logs" {
  count  = var.enable_access_logging ? 1 : 0
  bucket = aws_s3_bucket.access_logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "access_logs" {
  count  = var.enable_access_logging ? 1 : 0
  bucket = aws_s3_bucket.access_logs[0].id

  rule {
    id     = "expire-old-logs"
    status = "Enabled"

    filter {}

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}

#---------------------------------------------------------------
# Main S3 Bucket for Static Website
#---------------------------------------------------------------

resource "aws_s3_bucket" "website" {
  bucket        = local.bucket_name
  force_destroy = var.force_destroy

  tags = local.common_tags
}

# Bucket Ownership Controls
resource "aws_s3_bucket_ownership_controls" "website" {
  bucket = aws_s3_bucket.website.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Public Access Block Configuration
resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = !var.enable_public_access
  block_public_policy     = !var.enable_public_access
  ignore_public_acls      = !var.enable_public_access
  restrict_public_buckets = !var.enable_public_access
}

# Website Configuration
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = var.index_document
  }

  error_document {
    key = var.error_document
  }

  dynamic "routing_rule" {
    for_each = var.routing_rules != null ? [var.routing_rules] : []
    content {
      condition {
        http_error_code_returned_equals = lookup(jsondecode(routing_rule.value), "http_error_code_returned_equals", null)
        key_prefix_equals               = lookup(jsondecode(routing_rule.value), "key_prefix_equals", null)
      }
      redirect {
        host_name               = lookup(jsondecode(routing_rule.value), "host_name", null)
        http_redirect_code      = lookup(jsondecode(routing_rule.value), "http_redirect_code", null)
        protocol                = lookup(jsondecode(routing_rule.value), "protocol", null)
        replace_key_prefix_with = lookup(jsondecode(routing_rule.value), "replace_key_prefix_with", null)
        replace_key_with        = lookup(jsondecode(routing_rule.value), "replace_key_with", null)
      }
    }
  }
}

# Versioning Configuration
resource "aws_s3_bucket_versioning" "website" {
  bucket = aws_s3_bucket.website.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

# Server-Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "website" {
  count  = var.enable_encryption ? 1 : 0
  bucket = aws_s3_bucket.website.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_key_id != null ? "aws:kms" : "AES256"
      kms_master_key_id = var.kms_key_id
    }
    bucket_key_enabled = var.kms_key_id != null ? true : false
  }
}

# Access Logging
resource "aws_s3_bucket_logging" "website" {
  count         = var.enable_access_logging ? 1 : 0
  bucket        = aws_s3_bucket.website.id
  target_bucket = aws_s3_bucket.access_logs[0].id
  target_prefix = var.access_log_prefix
}

# Lifecycle Rules
resource "aws_s3_bucket_lifecycle_configuration" "website" {
  count  = var.enable_lifecycle_rules ? 1 : 0
  bucket = aws_s3_bucket.website.id

  rule {
    id     = "transition-old-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_transition {
      noncurrent_days = var.transition_to_ia_days
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = var.transition_to_glacier_days
      storage_class   = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_version_expiration_days
    }
  }

  rule {
    id     = "abort-incomplete-multipart-uploads"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# CORS Configuration
resource "aws_s3_bucket_cors_configuration" "website" {
  count  = var.enable_cors ? 1 : 0
  bucket = aws_s3_bucket.website.id

  cors_rule {
    allowed_headers = var.cors_allowed_headers
    allowed_methods = var.cors_allowed_methods
    allowed_origins = var.cors_allowed_origins
    expose_headers  = ["ETag"]
    max_age_seconds = var.cors_max_age_seconds
  }
}

# Bucket Policy for Public Access
resource "aws_s3_bucket_policy" "website" {
  count      = var.enable_public_access && !var.enable_cloudfront ? 1 : 0
  bucket     = aws_s3_bucket.website.id
  depends_on = [aws_s3_bucket_public_access_block.website]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })
}

# Request Metrics
resource "aws_s3_bucket_metric" "website" {
  count  = var.enable_metrics ? 1 : 0
  bucket = aws_s3_bucket.website.id
  name   = "EntireBucket"
}

# S3 Inventory Configuration
resource "aws_s3_bucket_inventory" "website" {
  count  = var.enable_inventory ? 1 : 0
  bucket = aws_s3_bucket.website.id
  name   = "EntireBucketInventory"

  included_object_versions = "All"
  schedule {
    frequency = var.inventory_frequency
  }

  destination {
    bucket {
      format     = "CSV"
      bucket_arn = aws_s3_bucket.website.arn
      prefix     = "inventory"
    }
  }
}

#---------------------------------------------------------------
# CloudFront Distribution (Optional)
#---------------------------------------------------------------

# Origin Access Identity for CloudFront
resource "aws_cloudfront_origin_access_identity" "website" {
  count   = var.enable_cloudfront ? 1 : 0
  comment = "OAI for ${local.bucket_name}"
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "website" {
  count               = var.enable_cloudfront ? 1 : 0
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for ${local.bucket_name}"
  default_root_object = var.index_document
  price_class         = var.cloudfront_price_class
  aliases             = var.custom_domain != null ? [var.custom_domain] : []

  origin {
    domain_name = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id   = "S3-${local.bucket_name}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.website[0].cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${local.bucket_name}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  dynamic "viewer_certificate" {
    for_each = var.custom_domain != null && var.acm_certificate_arn != null ? [1] : []
    content {
      acm_certificate_arn      = var.acm_certificate_arn
      ssl_support_method       = "sni-only"
      minimum_protocol_version = "TLSv1.2_2021"
    }
  }

  dynamic "viewer_certificate" {
    for_each = var.custom_domain == null || var.acm_certificate_arn == null ? [1] : []
    content {
      cloudfront_default_certificate = true
    }
  }

  custom_error_response {
    error_code         = 404
    response_code      = 404
    response_page_path = "/${var.error_document}"
  }

  custom_error_response {
    error_code         = 403
    response_code      = 403
    response_page_path = "/${var.error_document}"
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.bucket_name}-cf"
    }
  )
}

# CloudFront-specific Bucket Policy
resource "aws_s3_bucket_policy" "cloudfront" {
  count  = var.enable_cloudfront ? 1 : 0
  bucket = aws_s3_bucket.website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudFrontReadGetObject"
        Effect = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.website[0].iam_arn
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })
}

#---------------------------------------------------------------
# CloudWatch Alarms
#---------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "high_4xx_errors" {
  count               = var.enable_cloudfront && var.enable_metrics ? 1 : 0
  alarm_name          = "${local.bucket_name}-high-4xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "4xxErrorRate"
  namespace           = "AWS/CloudFront"
  period              = "300"
  statistic           = "Average"
  threshold           = "5"
  alarm_description   = "Monitors CloudFront 4xx error rate"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DistributionId = aws_cloudfront_distribution.website[0].id
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "high_5xx_errors" {
  count               = var.enable_cloudfront && var.enable_metrics ? 1 : 0
  alarm_name          = "${local.bucket_name}-high-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "5xxErrorRate"
  namespace           = "AWS/CloudFront"
  period              = "300"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "Monitors CloudFront 5xx error rate"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DistributionId = aws_cloudfront_distribution.website[0].id
  }

  tags = local.common_tags
}

