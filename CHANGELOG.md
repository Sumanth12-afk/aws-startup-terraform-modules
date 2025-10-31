## [1.0.2](https://github.com/Sumanth12-afk/aws-startup-terraform-modules/compare/v1.0.1...v1.0.2) (2025-10-31)


### Bug Fixes

* resolve ECS service validation errors and tfsec security scan permissions ([56d259f](https://github.com/Sumanth12-afk/aws-startup-terraform-modules/commit/56d259f7f8e3c338bb19a22b6563f6e79a321e5e))
* update CI/CD Terraform version to 1.10.5 to match local environment ([dfafdb0](https://github.com/Sumanth12-afk/aws-startup-terraform-modules/commit/dfafdb01aa39c0e46dc38acb189c2471f700d9cc))

## [1.0.1](https://github.com/Sumanth12-afk/aws-startup-terraform-modules/compare/v1.0.0...v1.0.1) (2025-10-31)


### Bug Fixes

* add GitHub Actions permissions for semantic-release ([980285a](https://github.com/Sumanth12-afk/aws-startup-terraform-modules/commit/980285a70c3fc6ce36346dbae91bda3098e51fba))

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial repository setup with production-ready modules
- Complete CI/CD pipeline with validation, linting, and security scanning
- Terraform Registry compliance
- AWS Marketplace readiness preparation

## [1.0.0] - 2025-10-31

### ✨ Features

#### Networking Modules
- **vpc-networking**: Multi-AZ VPC with public/private/database subnets
  - VPC Flow Logs to S3
  - NAT Gateway support (HA and cost-optimized options)
  - IPv6 support
  - Custom DHCP options
- **alb-loadbalancer**: Application Load Balancer with SSL/TLS
  - Path-based routing
  - Multiple target groups
  - CloudWatch alarms
  - WAF-ready
- **internet-gateway-nat**: Standalone IGW/NAT Gateway management

#### Compute Modules
- **ecs-fargate-service**: Serverless container deployment
  - Fargate Spot support (70% cost savings)
  - Auto-scaling (CPU and memory-based)
  - Service Discovery integration
  - ECS Exec support
  - Container Insights
- **lambda-api-gateway**: Serverless REST API
  - Multiple Lambda functions
  - API Gateway integration
  - Custom domains with SSL
  - API keys and usage plans
  - X-Ray tracing
  - CORS support

#### Storage & Databases
- **rds-postgres-database**: In progress
  - Multi-AZ support
  - Read replicas
  - Automated backups
  - Performance Insights

### 📖 Documentation
- Comprehensive README for each module
- Root README with category overview
- GETTING_STARTED.md with quick start guide
- IMPLEMENTATION_GUIDE.md for creating new modules
- PROJECT_STATUS.md tracking progress
- CONTRIBUTING.md with contribution guidelines
- Architecture diagrams and cost estimates

### 🔒 Security
- Encryption at rest and in transit enabled by default
- Least-privilege IAM roles
- Security groups with minimal access
- VPC Flow Logs
- CloudTrail logging support
- Secrets Manager integration

### 💰 Cost Optimization
- Fargate Spot support
- Single NAT Gateway option for dev/staging
- Right-sized resource defaults
- S3 lifecycle policies
- Auto-scaling policies

### 🚀 CI/CD & Automation
- GitHub Actions workflows for validation
- Terraform format checking
- tflint and tfsec security scanning
- Automated documentation generation
- Semantic versioning
- Pre-commit hooks

### 📦 Terraform Registry
- Registry-compliant module structure
- Semantic versioning
- Complete input/output documentation
- Working examples for all modules

### 🏢 AWS Marketplace Readiness
- Pro/Enterprise tier documentation
- Pricing structure defined
- Support model documented
- Feature comparison tables

## [0.1.0] - 2025-10-30

### Added
- Initial project structure
- Basic module templates

---

## Release Notes

### How to Upgrade

For upgrading between versions, please review the specific version's changes above and follow these general steps:

1. **Backup your state**: 
   ```bash
   terraform state pull > backup.tfstate
   ```

2. **Update module version**:
   ```hcl
   module "vpc" {
     source  = "Sumanth12-afk/startup-infrastructure/aws//networking/vpc-networking"
     version = "~> 1.0"  # Update to desired version
   }
   ```

3. **Run terraform plan**:
   ```bash
   terraform plan
   ```

4. **Review changes carefully** before applying

5. **Apply updates**:
   ```bash
   terraform apply
   ```

### Breaking Changes

#### v1.0.0
- None (initial release)

### Deprecations

- None currently

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for information on how to contribute to this project.

## Support

See [SUPPORT.md](SUPPORT.md) for information on getting help.

---

[Unreleased]: https://github.com/Sumanth12-afk/aws-startup-terraform-modules/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/Sumanth12-afk/aws-startup-terraform-modules/releases/tag/v1.0.0
[0.1.0]: https://github.com/Sumanth12-afk/aws-startup-terraform-modules/releases/tag/v0.1.0
