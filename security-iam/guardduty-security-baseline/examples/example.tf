module "security_baseline" {
  source = "../"

  environment = "production"

  enable_guardduty     = true
  enable_security_hub  = true
  enable_config        = true
  create_sns_topic     = true

  config_s3_bucket_name = "my-config-logs"

  tags = {
    Project = "Security"
  }
}

output "guardduty_detector_id" {
  value = module.security_baseline.guardduty_detector_id
}

