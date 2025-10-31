# GuardDuty Security Baseline Module

Comprehensive security baseline with GuardDuty, Security Hub, and AWS Config.

## Usage

```hcl
module "security" {
  source = "github.com/yourusername/aws-startup-terraform-modules//security-iam/guardduty-security-baseline?ref=v1.0.0"

  environment = "production"

  enable_guardduty    = true
  enable_security_hub = true
  enable_config       = true

  config_s3_bucket_name = "my-config-logs"

  tags = { Project = "Security" }
}
```

## Features

- ✅ GuardDuty threat detection
- ✅ Security Hub centralization
- ✅ AWS Config compliance
- ✅ SNS alerts

## License

MIT License

