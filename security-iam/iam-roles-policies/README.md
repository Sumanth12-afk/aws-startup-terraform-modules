# IAM Roles & Policies Module

[![Terraform](https://img.shields.io/badge/Terraform-1.5+-623CE4?logo=terraform)](https://www.terraform.io/)
[![AWS Provider](https://img.shields.io/badge/AWS-5.0+-FF9900?logo=amazon-aws)](https://registry.terraform.io/providers/hashicorp/aws/latest)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](../LICENSE)

## Overview

Production-ready IAM roles and policies module with support for service roles, cross-account access, MFA requirements, and instance profiles.

### Key Features

- ✅ **Service Roles**: ECS, Lambda, EC2, etc.
- ✅ **Cross-Account Access**: With optional MFA
- ✅ **Managed Policies**: Attach AWS-managed policies
- ✅ **Inline Policies**: Custom policy documents
- ✅ **Instance Profiles**: For EC2 instances
- ✅ **Permissions Boundary**: Enforce security limits

---

## Usage

```hcl
module "ecs_role" {
  source = "github.com/yourusername/aws-startup-terraform-modules//security-iam/iam-roles-policies?ref=v1.0.0"

  environment = "production"
  role_name   = "ecs-task-role"

  trusted_services = ["ecs-tasks.amazonaws.com"]

  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]

  inline_policies = {
    "s3-access" = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "arn:aws:s3:::my-bucket/*"
      }]
    })
  }

  tags = { Project = "MyApp" }
}
```

---

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `role_name` | IAM role name | `string` | n/a | yes |
| `trusted_services` | AWS services that can assume role | `list(string)` | `[]` | no |
| `policy_arns` | Managed policy ARNs to attach | `list(string)` | `[]` | no |
| `inline_policies` | Map of inline policies | `map(string)` | `{}` | no |
| `create_instance_profile` | Create EC2 instance profile | `bool` | `false` | no |
| `require_mfa` | Require MFA for assume role | `bool` | `false` | no |
| `tags` | Additional tags | `map(string)` | `{}` | no |

---

## Outputs

| Name | Description |
|------|-------------|
| `role_arn` | IAM role ARN |
| `role_name` | IAM role name |
| `instance_profile_name` | Instance profile name (if created) |

---

## License

MIT License - See [LICENSE](LICENSE) for details.

---

**Made with ❤️ by the AWS Startup Terraform Modules team**

