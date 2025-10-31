# KMS Encryption Module

Production-ready KMS encryption keys with automatic rotation and granular access control.

## Usage

```hcl
module "kms" {
  source = "github.com/yourusername/aws-startup-terraform-modules//security-iam/kms-encryption?ref=v1.0.0"

  environment = "production"
  key_alias   = "database-encryption"

  enable_key_rotation = true

  key_users = [
    "arn:aws:iam::123456789012:role/ECSTaskRole"
  ]

  tags = { Project = "MyApp" }
}
```

## Features

- ✅ Automatic key rotation
- ✅ Granular access control
- ✅ Multi-region support
- ✅ Audit logging

## License

MIT License

