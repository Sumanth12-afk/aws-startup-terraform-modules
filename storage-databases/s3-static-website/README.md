# S3 Static Website Module

[![Terraform](https://img.shields.io/badge/Terraform-1.5+-623CE4?logo=terraform)](https://www.terraform.io/)
[![AWS Provider](https://img.shields.io/badge/AWS-5.0+-FF9900?logo=amazon-aws)](https://registry.terraform.io/providers/hashicorp/aws/latest)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](../LICENSE)

## Overview

Production-ready S3 static website hosting module with optional CloudFront CDN integration, custom domains, SSL/TLS, versioning, lifecycle management, and comprehensive security features.

### Key Features

- ✅ **Static Website Hosting**: Serve HTML, CSS, JS, and other static assets
- ✅ **CloudFront CDN**: Optional global content delivery with caching
- ✅ **Custom Domains**: SSL/TLS certificates via ACM
- ✅ **Security**: Encryption at rest, access logging, CORS support
- ✅ **Versioning**: Protect against accidental deletions
- ✅ **Lifecycle Management**: Automatic storage class transitions
- ✅ **Cost Optimization**: Intelligent tiering and storage classes

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                   CloudFront Distribution                       │
│         (Optional - Global Edge Locations)                      │
│  ┌──────────────────────────────────────────────────────┐      │
│  │  Custom Domain: www.example.com                      │      │
│  │  SSL Certificate (ACM)                               │      │
│  │  Cache Behaviors & TTL Rules                         │      │
│  └─────────────┬────────────────────────────────────────┘      │
└────────────────┼───────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                    S3 Static Website Bucket                     │
│  ┌──────────────────────────────────────────────────────┐      │
│  │  /index.html                                         │      │
│  │  /assets/                                            │      │
│  │    ├── css/style.css                                 │      │
│  │    ├── js/app.js                                     │      │
│  │    └── images/logo.png                               │      │
│  │  /error.html                                         │      │
│  └──────────────────────────────────────────────────────┘      │
│                                                                 │
│  Features:                                                      │
│  • Website hosting enabled                                      │
│  • Versioning enabled                                           │
│  • Encryption at rest (AES256 or KMS)                          │
│  • Public access OR CloudFront OAI                             │
│  • CORS configuration                                           │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                 S3 Access Logs Bucket                           │
│  • Stores access logs for audit and analytics                  │
│  • Lifecycle: IA (30d) → Glacier (90d) → Expire (365d)        │
└─────────────────────────────────────────────────────────────────┘
```

---

## Usage Example

### Basic Static Website

```hcl
module "website" {
  source = "github.com/yourusername/aws-startup-terraform-modules//storage-databases/s3-static-website?ref=v1.0.0"

  environment          = "production"
  bucket_name          = "my-website-2024"
  enable_public_access = true
  enable_versioning    = true

  tags = {
    Project = "MyWebsite"
  }
}
```

### Production Website with CloudFront

```hcl
module "production_website" {
  source = "github.com/yourusername/aws-startup-terraform-modules//storage-databases/s3-static-website?ref=v1.0.0"

  environment = "production"
  aws_region  = "us-east-1"

  bucket_name   = "my-production-website"
  force_destroy = false

  # CloudFront Configuration
  enable_cloudfront      = true
  cloudfront_price_class = "PriceClass_100"
  custom_domain          = "www.example.com"
  acm_certificate_arn    = module.acm.certificate_arn

  # Security
  enable_encryption    = true
  enable_public_access = false  # CloudFront only

  # Lifecycle
  enable_lifecycle_rules             = true
  noncurrent_version_expiration_days = 30

  # Monitoring
  enable_metrics        = true
  enable_access_logging = true

  tags = {
    Project = "MyWebsite"
    Owner   = "WebTeam"
  }
}

# Deploy website files
resource "null_resource" "deploy_website" {
  provisioner "local-exec" {
    command = module.production_website.s3_sync_command
    working_dir = "./dist"
  }

  triggers = {
    bucket_id = module.production_website.bucket_id
  }
}
```

---

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `environment` | Environment name | `string` | n/a | yes |
| `bucket_name` | S3 bucket name (globally unique) | `string` | n/a | yes |
| `enable_cloudfront` | Enable CloudFront CDN | `bool` | `false` | no |
| `enable_public_access` | Enable public read access | `bool` | `true` | no |
| `enable_versioning` | Enable S3 versioning | `bool` | `true` | no |
| `enable_encryption` | Enable server-side encryption | `bool` | `true` | no |
| `custom_domain` | Custom domain name | `string` | `null` | no |
| `acm_certificate_arn` | ACM certificate ARN | `string` | `null` | no |
| `tags` | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `deployment_url` | Primary URL for accessing website |
| `bucket_id` | S3 bucket name |
| `cloudfront_distribution_id` | CloudFront distribution ID |
| `s3_sync_command` | AWS CLI command to sync files |

---

## Deployment Guide

### 1. Create Infrastructure

```bash
terraform init
terraform plan
terraform apply
```

### 2. Deploy Website Files

```bash
# Sync your website files
aws s3 sync ./dist s3://your-bucket-name/ --delete

# If using CloudFront, invalidate cache
aws cloudfront create-invalidation \
  --distribution-id E1234567890ABC \
  --paths "/*"
```

### 3. Configure DNS (if using custom domain)

Add CNAME record in your DNS provider:
```
www.example.com  →  d111111abcdef8.cloudfront.net
```

---

## Cost Optimization

| Configuration | Storage | Requests | CloudFront | Total/Month |
|---------------|---------|----------|------------|-------------|
| **Basic** | 1GB | 10K requests | N/A | ~$0.50 |
| **Medium** | 10GB | 100K requests | + CloudFront | ~$15 |
| **High Traffic** | 50GB | 1M requests | + CloudFront | ~$80 |

---

## Pro Version Features

| Feature | Free | Pro | Enterprise |
|---------|------|-----|------------|
| **WAF Integration** | ❌ | ✅ | ✅ |
| **Lambda@Edge** | ❌ | ✅ | ✅ |
| **Real-Time Logs** | ❌ | ✅ | ✅ |
| **DDoS Protection** | ❌ | ❌ | ✅ |
| **24/7 Support** | ❌ | ❌ | ✅ |

---

## License

MIT License - See [LICENSE](LICENSE) for details.

---

**Made with ❤️ by the AWS Startup Terraform Modules team**

