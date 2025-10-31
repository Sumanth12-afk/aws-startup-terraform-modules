# CloudTrail Audit Logs Module

Complete audit logging solution with CloudTrail, S3 storage, and optional CloudWatch Logs integration.

## Usage

```hcl
module "cloudtrail" {
  source = "github.com/yourusername/aws-startup-terraform-modules//security-iam/cloudtrail-audit-logs?ref=v1.0.0"

  environment    = "production"
  trail_name     = "audit-trail"
  s3_bucket_name = "my-audit-logs"

  is_multi_region_trail      = true
  enable_log_file_validation = true

  tags = { Project = "Security" }
}
```

## Features

- ✅ Multi-region support
- ✅ Log file validation
- ✅ S3 lifecycle policies
- ✅ KMS encryption
- ✅ CloudWatch Logs integration

## License

MIT License

