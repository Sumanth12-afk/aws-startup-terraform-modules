# ElastiCache Redis Module

[![Terraform](https://img.shields.io/badge/Terraform-1.5+-623CE4?logo=terraform)](https://www.terraform.io/)
[![AWS Provider](https://img.shields.io/badge/AWS-5.0+-FF9900?logo=amazon-aws)](https://registry.terraform.io/providers/hashicorp/aws/latest)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](../LICENSE)

## Overview

Production-ready ElastiCache Redis module with cluster mode, high availability, automatic failover, encryption, and comprehensive monitoring.

### Key Features

- ✅ **High Availability**: Multi-AZ deployment with automatic failover
- ✅ **Cluster Mode**: Horizontal scaling with sharding
- ✅ **Security**: Encryption at rest/transit, AUTH tokens
- ✅ **Backups**: Automated snapshots and point-in-time recovery
- ✅ **Monitoring**: CloudWatch alarms for key metrics
- ✅ **Flexible**: Single node, replicated, or cluster mode

---

## Usage

```hcl
module "redis" {
  source = "github.com/yourusername/aws-startup-terraform-modules//storage-databases/elasticache-redis?ref=v1.0.0"

  environment = "production"
  cluster_id  = "myapp-redis"

  node_type       = "cache.r6g.large"
  num_cache_nodes = 2  # Primary + 1 replica

  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnet_ids
  allowed_cidr_blocks = [module.vpc.vpc_cidr]

  automatic_failover_enabled = true
  multi_az_enabled           = true

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  auth_token                 = var.redis_password

  snapshot_retention_limit = 7

  tags = {
    Project = "MyApp"
  }
}
```

---

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `cluster_id` | Redis cluster identifier | `string` | n/a | yes |
| `node_type` | Instance type | `string` | `"cache.t4g.micro"` | no |
| `num_cache_nodes` | Number of nodes | `number` | `1` | no |
| `vpc_id` | VPC ID | `string` | n/a | yes |
| `subnet_ids` | Subnet IDs | `list(string)` | n/a | yes |
| `automatic_failover_enabled` | Enable auto-failover | `bool` | `true` | no |
| `at_rest_encryption_enabled` | Enable encryption at rest | `bool` | `true` | no |
| `transit_encryption_enabled` | Enable encryption in transit | `bool` | `true` | no |
| `tags` | Additional tags | `map(string)` | `{}` | no |

---

## Outputs

| Name | Description |
|------|-------------|
| `primary_endpoint_address` | Primary endpoint address |
| `connection_string` | Redis connection string |
| `security_group_id` | Security group ID |

---

## Cost Optimization

| Configuration | Node Type | Monthly Cost (est.) |
|---------------|-----------|---------------------|
| **Dev/Test** | cache.t4g.micro | ~$12 |
| **Small Prod** | cache.r6g.large | ~$160 |
| **Medium Prod** | cache.r6g.xlarge (3 shards) | ~$1,500 |

---

## Pro Features

| Feature | Free | Pro | Enterprise |
|---------|------|-----|------------|
| **Global Datastore** | ❌ | ✅ | ✅ |
| **Data Tiering** | ❌ | ✅ | ✅ |
| **Redis 7.x Features** | ✅ | ✅ | ✅ |
| **24/7 Support** | ❌ | ❌ | ✅ |

---

## License

MIT License - See [LICENSE](LICENSE) for details.

---

**Made with ❤️ by the AWS Startup Terraform Modules team**

