# Secrets Manager Module

Secure storage for sensitive data with automatic rotation and encryption.

## Usage

```hcl
module "secret" {
  source = "github.com/yourusername/aws-startup-terraform-modules//security-iam/secrets-manager?ref=v1.0.0"

  environment = "production"
  secret_name = "api-keys"

  secret_string = jsonencode({
    api_key = var.api_key
  })

  kms_key_id      = module.kms.key_id
  enable_rotation = true
  rotation_days   = 30

  tags = { Project = "MyApp" }
}
```

## Features

- ✅ KMS encryption
- ✅ Automatic rotation
- ✅ Version management
- ✅ IAM policy support

## License

MIT License

