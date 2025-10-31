environment = "production"
aws_region  = "us-east-1"

enable_guardduty              = true
finding_publishing_frequency  = "FIFTEEN_MINUTES"
enable_s3_protection         = true
enable_kubernetes_protection = true
enable_malware_protection    = true

enable_security_hub      = true
enable_default_standards = true

enable_config            = true
config_s3_bucket_name    = "my-aws-config-logs"
include_global_resources = true

create_sns_topic = true

tags = {
  Project    = "Security"
  Purpose    = "ThreatDetection"
  Compliance = "Required"
}

