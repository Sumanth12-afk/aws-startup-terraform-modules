module "cloudtrail" {
  source = "../"

  environment    = "production"
  trail_name     = "organization-trail"
  s3_bucket_name = "my-cloudtrail-logs"

  is_multi_region_trail        = true
  enable_log_file_validation   = true
  enable_cloudwatch_logs       = true

  kms_key_id = module.kms.key_id

  tags = {
    Project = "Security"
    Purpose = "Audit"
  }
}

output "trail_arn" {
  value = module.cloudtrail.trail_arn
}

