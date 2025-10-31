# DynamoDB NoSQL Table Module

[![Terraform](https://img.shields.io/badge/Terraform-1.5+-623CE4?logo=terraform)](https://www.terraform.io/)
[![AWS Provider](https://img.shields.io/badge/AWS-5.0+-FF9900?logo=amazon-aws)](https://registry.terraform.io/providers/hashicorp/aws/latest)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](../LICENSE)

## Overview

Production-ready DynamoDB table module with on-demand/provisioned billing, global secondary indexes, auto-scaling, streams, point-in-time recovery, and global table support.

### Key Features

- ✅ **Flexible Billing**: On-demand or provisioned capacity with auto-scaling
- ✅ **Indexing**: Global and local secondary indexes
- ✅ **Streams**: Real-time data capture for triggers and replication
- ✅ **High Availability**: Point-in-time recovery, automated backups
- ✅ **Global Tables**: Multi-region replication
- ✅ **Security**: Encryption at rest, IAM integration
- ✅ **Monitoring**: CloudWatch alarms for throttling and errors

---

## Usage

```hcl
module "users_table" {
  source = "github.com/yourusername/aws-startup-terraform-modules//storage-databases/dynamodb-nosql-table?ref=v1.0.0"

  environment  = "production"
  table_name   = "users"
  billing_mode = "PAY_PER_REQUEST"

  hash_key      = "user_id"
  range_key     = "created_at"

  attributes = [
    { name = "email", type = "S" }
  ]

  global_secondary_indexes = [{
    name            = "email-index"
    hash_key        = "email"
    projection_type = "ALL"
  }]

  enable_streams                 = true
  enable_point_in_time_recovery = true
  enable_encryption              = true

  tags = {
    Project = "MyApp"
  }
}
```

---

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `table_name` | DynamoDB table name | `string` | n/a | yes |
| `billing_mode` | PROVISIONED or PAY_PER_REQUEST | `string` | `"PAY_PER_REQUEST"` | no |
| `hash_key` | Partition key attribute name | `string` | n/a | yes |
| `range_key` | Sort key attribute name | `string` | `null` | no |
| `global_secondary_indexes` | List of GSIs | `list(object)` | `[]` | no |
| `enable_streams` | Enable DynamoDB streams | `bool` | `false` | no |
| `enable_point_in_time_recovery` | Enable PITR | `bool` | `true` | no |
| `tags` | Additional tags | `map(string)` | `{}` | no |

---

## Outputs

| Name | Description |
|------|-------------|
| `table_arn` | Table ARN |
| `table_name` | Table name |
| `table_stream_arn` | Stream ARN (if enabled) |

---

## Cost Optimization

| Configuration | Billing Mode | Monthly Cost (est.) |
|---------------|--------------|---------------------|
| **Dev/Test** | On-Demand | $1-5 (light usage) |
| **Production** | On-Demand | $25-100 (moderate) |
| **Enterprise** | Provisioned + Auto-Scaling | $50-500+ |

**Tip**: Use on-demand for unpredictable workloads, provisioned for steady traffic.

---

## Pro Features

| Feature | Free | Pro | Enterprise |
|---------|------|-----|------------|
| **DAX Caching** | ❌ | ✅ | ✅ |
| **Global Tables** | ✅ | ✅ | ✅ |
| **Point-in-Time Recovery** | ✅ | ✅ | ✅ |
| **Multi-Region Active-Active** | ❌ | ❌ | ✅ |
| **24/7 Support** | ❌ | ❌ | ✅ |

---

## License

MIT License - See [LICENSE](LICENSE) for details.

---

**Made with ❤️ by the AWS Startup Terraform Modules team**

