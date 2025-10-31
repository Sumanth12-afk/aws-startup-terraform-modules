# Security & IAM Modules

This category contains production-ready Terraform modules for AWS security and identity management services.

## 🔐 Available Modules

| Module | Description | Use Case |
|--------|-------------|----------|
| **[iam-roles-policies](./iam-roles-policies/)** | IAM roles, policies, instance profiles | Service roles, cross-account access |
| **[kms-encryption](./kms-encryption/)** | KMS keys for encryption at rest | Database, S3, EBS encryption |
| **[secrets-manager](./secrets-manager/)** | Secrets storage with rotation | API keys, database credentials |
| **[guardduty-security-baseline](./guardduty-security-baseline/)** | GuardDuty, Security Hub, Config | Threat detection, compliance |
| **[cloudtrail-audit-logs](./cloudtrail-audit-logs/)** | CloudTrail for audit logging | Compliance, forensics |

---

## 🏗️ Architecture Overview

```
┌──────────────────────────────────────────────────────────────────┐
│                      Security & IAM Layer                        │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                    Identity & Access                        │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │ │
│  │  │  IAM Roles   │  │  IAM         │  │  Instance    │     │ │
│  │  │  & Policies  │  │  Users       │  │  Profiles    │     │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘     │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                    Encryption & Secrets                     │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │ │
│  │  │  KMS Keys    │  │  Secrets     │  │  Parameter   │     │ │
│  │  │  (Envelope   │  │  Manager     │  │  Store       │     │ │
│  │  │  Encryption) │  │  (Rotation)  │  │  (Config)    │     │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘     │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │              Threat Detection & Monitoring                  │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │ │
│  │  │  GuardDuty   │  │  Security    │  │  AWS         │     │ │
│  │  │  (Threat     │  │  Hub         │  │  Config      │     │ │
│  │  │  Detection)  │  │  (Central)   │  │  (Rules)     │     │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘     │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                   Audit & Compliance                        │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │ │
│  │  │  CloudTrail  │  │  CloudWatch  │  │  S3 Logs     │     │ │
│  │  │  (API Logs)  │  │  Logs        │  │  (Archive)   │     │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘     │ │
│  └────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────┘
```

---

## 🚀 Quick Start

### 1. IAM Roles & Policies

```hcl
module "ecs_task_role" {
  source = "github.com/yourusername/aws-startup-terraform-modules//security-iam/iam-roles-policies?ref=v1.0.0"

  environment = "production"
  role_name   = "ecs-task-role"
  
  trusted_services = ["ecs-tasks.amazonaws.com"]
  
  policy_arns = [
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
  ]

  tags = { Project = "MyApp" }
}
```

### 2. KMS Encryption Keys

```hcl
module "database_kms_key" {
  source = "github.com/yourusername/aws-startup-terraform-modules//security-iam/kms-encryption?ref=v1.0.0"

  environment = "production"
  key_alias   = "database-encryption"
  description = "KMS key for RDS database encryption"
  
  key_administrators = ["arn:aws:iam::123456789012:role/Admin"]
  key_users          = ["arn:aws:iam::123456789012:role/ECSTaskRole"]

  tags = { Purpose = "Database" }
}
```

### 3. Secrets Manager

```hcl
module "db_credentials" {
  source = "github.com/yourusername/aws-startup-terraform-modules//security-iam/secrets-manager?ref=v1.0.0"

  environment   = "production"
  secret_name   = "database-credentials"
  description   = "RDS database credentials"
  
  secret_string = jsonencode({
    username = "admin"
    password = var.db_password
    host     = module.rds.endpoint
  })

  enable_rotation = true
  rotation_days   = 30

  tags = { Type = "DatabaseCredentials" }
}
```

---

## 💰 Cost Optimization

| Service | Usage | Monthly Cost |
|---------|-------|--------------|
| **IAM** | Free | $0 |
| **KMS** | 1 key + 10K requests | ~$1 |
| **Secrets Manager** | 5 secrets + 10K requests | ~$2 |
| **GuardDuty** | 1 account, moderate events | ~$30-50 |
| **Security Hub** | 1 account | ~$5-10 |
| **CloudTrail** | Management events only | ~$2 |
| **Total** | | **~$40-65/month** |

---

## 🔒 Security Best Practices

### IAM
- ✅ Use roles instead of access keys
- ✅ Enable MFA for privileged users
- ✅ Follow least privilege principle
- ✅ Rotate credentials regularly
- ✅ Use service-specific roles

### KMS
- ✅ Use customer-managed keys for sensitive data
- ✅ Enable key rotation (automatic yearly)
- ✅ Separate keys by environment
- ✅ Implement key policies with least privilege
- ✅ Monitor key usage with CloudWatch

### Secrets Manager
- ✅ Enable automatic rotation
- ✅ Use VPC endpoints for private access
- ✅ Implement resource policies
- ✅ Enable encryption with KMS
- ✅ Tag secrets for compliance

### GuardDuty & Security Hub
- ✅ Enable in all regions
- ✅ Configure automated remediation
- ✅ Integrate with SNS for alerts
- ✅ Review findings regularly
- ✅ Enable threat intelligence feeds

### CloudTrail
- ✅ Enable in all regions
- ✅ Log to S3 with encryption
- ✅ Enable log file validation
- ✅ Configure CloudWatch Logs integration
- ✅ Set up SNS notifications for critical events

---

## 🎓 Pro Version Features

| Feature | Free | Pro | Enterprise |
|---------|------|-----|------------|
| **Cross-Account IAM** | ✅ | ✅ | ✅ |
| **KMS Multi-Region Keys** | ❌ | ✅ | ✅ |
| **Secrets Replication** | ❌ | ✅ | ✅ |
| **GuardDuty Org-Wide** | ❌ | ✅ | ✅ |
| **Custom Security Rules** | ❌ | ✅ | ✅ |
| **Automated Remediation** | ❌ | ❌ | ✅ |
| **24/7 Security Monitoring** | ❌ | ❌ | ✅ |

---

## License

MIT License - See [LICENSE](../LICENSE) for details.

---

**Made with ❤️ by the AWS Startup Terraform Modules team**

