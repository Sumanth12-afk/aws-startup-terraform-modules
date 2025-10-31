environment    = "production"
aws_region     = "us-east-1"
trail_name     = "organization-audit-trail"
s3_bucket_name = "my-organization-cloudtrail-logs"

include_global_service_events = true
is_multi_region_trail         = true
enable_log_file_validation    = true

# KMS encryption (optional)
# kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/abc123"

# CloudWatch Logs (optional)
enable_cloudwatch_logs = false
log_retention_days     = 90

# Lifecycle
transition_to_ia_days      = 90
transition_to_glacier_days = 180
expiration_days            = 2555 # 7 years

force_destroy = false

tags = {
  Project    = "Security"
  Purpose    = "AuditLogging"
  Compliance = "Required"
}

