# Storage & Databases Modules

This category contains production-ready Terraform modules for AWS storage and database services optimized for startup workloads.

## 📦 Available Modules

| Module | Description | Use Case |
|--------|-------------|----------|
| **[rds-postgres-database](./rds-postgres-database/)** | Managed PostgreSQL with Multi-AZ, backups, Performance Insights | Relational data, transactions |
| **[s3-static-website](./s3-static-website/)** | S3 static hosting with CloudFront, custom domains, SSL | Static sites, SPAs, assets |
| **[dynamodb-nosql-table](./dynamodb-nosql-table/)** | DynamoDB with GSI, streams, auto-scaling, global tables | NoSQL, high-scale apps |
| **[elasticache-redis](./elasticache-redis/)** | Redis with cluster mode, HA, encryption | Caching, sessions, queues |

---

## 🏗️ Architecture Overview

```
┌──────────────────────────────────────────────────────────────────┐
│                   Application Layer                              │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐                 │
│  │  Web App   │  │  API       │  │  Workers   │                 │
│  └──────┬─────┘  └──────┬─────┘  └──────┬─────┘                 │
└─────────┼────────────────┼────────────────┼───────────────────────┘
          │                │                │
          ▼                ▼                ▼
┌──────────────────────────────────────────────────────────────────┐
│                   Storage & Database Layer                       │
│                                                                  │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────┐  │
│  │   RDS PostgreSQL │  │  DynamoDB Tables │  │  ElastiCache │  │
│  │  ┌────────────┐  │  │  ┌────────────┐  │  │  ┌────────┐  │  │
│  │  │  Primary   │  │  │  │  Users     │  │  │  │ Redis  │  │  │
│  │  │  Instance  │  │  │  │  Sessions  │  │  │  │ Cluster│  │  │
│  │  └──────┬─────┘  │  │  │  Metadata  │  │  │  └────────┘  │  │
│  │         │        │  │  └────────────┘  │  │              │  │
│  │  ┌──────▼─────┐  │  │                  │  │              │  │
│  │  │  Replica   │  │  │  Global Tables   │  │  Multi-AZ    │  │
│  │  │  (Read)    │  │  │  (Multi-Region)  │  │  Failover    │  │
│  │  └────────────┘  │  │                  │  │              │  │
│  └──────────────────┘  └──────────────────┘  └──────────────┘  │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                      S3 Storage                            │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐       │ │
│  │  │  Static     │  │  User       │  │  Backups    │       │ │
│  │  │  Website    │  │  Uploads    │  │  & Archives │       │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘       │ │
│  │                                                            │ │
│  │  CloudFront CDN (Optional)                                │ │
│  └────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────┘
```

---

## 🚀 Quick Start

### 1. RDS PostgreSQL Database

```hcl
module "postgres" {
  source = "github.com/yourusername/aws-startup-terraform-modules//storage-databases/rds-postgres-database?ref=v1.0.0"

  environment   = "production"
  db_name       = "myapp"
  instance_class = "db.t4g.medium"

  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnet_ids
  allowed_cidr_blocks = [module.vpc.vpc_cidr]

  multi_az                = true
  backup_retention_period = 7

  tags = { Project = "MyApp" }
}
```

### 2. S3 Static Website

```hcl
module "website" {
  source = "github.com/yourusername/aws-startup-terraform-modules//storage-databases/s3-static-website?ref=v1.0.0"

  environment          = "production"
  bucket_name          = "my-website-2024"
  enable_cloudfront    = true
  custom_domain        = "www.example.com"
  acm_certificate_arn  = module.acm.certificate_arn

  tags = { Project = "MyWebsite" }
}
```

### 3. DynamoDB Table

```hcl
module "users_table" {
  source = "github.com/yourusername/aws-startup-terraform-modules//storage-databases/dynamodb-nosql-table?ref=v1.0.0"

  environment  = "production"
  table_name   = "users"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"

  enable_streams                 = true
  enable_point_in_time_recovery = true

  tags = { Project = "MyApp" }
}
```

### 4. ElastiCache Redis

```hcl
module "redis" {
  source = "github.com/yourusername/aws-startup-terraform-modules//storage-databases/elasticache-redis?ref=v1.0.0"

  environment = "production"
  cluster_id  = "myapp-redis"
  node_type   = "cache.r6g.large"
  num_cache_nodes = 2

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  automatic_failover_enabled = true
  transit_encryption_enabled = true

  tags = { Project = "MyApp" }
}
```

---

## 💰 Cost Optimization Guide

### Startup Budget ($100-500/month)

| Service | Configuration | Monthly Cost |
|---------|---------------|--------------|
| **RDS** | db.t4g.medium, 100GB | ~$150 |
| **S3** | 10GB + CloudFront | ~$10 |
| **DynamoDB** | On-Demand, light usage | ~$5 |
| **Redis** | cache.t4g.small | ~$20 |
| **Total** | | **~$185** |

### Growth Stage ($500-2000/month)

| Service | Configuration | Monthly Cost |
|---------|---------------|--------------|
| **RDS** | db.r6g.large, 500GB, Multi-AZ | ~$600 |
| **S3** | 100GB + CloudFront | ~$50 |
| **DynamoDB** | Provisioned + Auto-Scale | ~$100 |
| **Redis** | cache.r6g.large, 2 nodes | ~$320 |
| **Total** | | **~$1,070** |

### Enterprise ($2000+/month)

| Service | Configuration | Monthly Cost |
|---------|---------------|--------------|
| **RDS** | db.r6g.2xlarge, 2TB, Multi-AZ + Replicas | ~$2,000 |
| **S3** | 1TB + Multi-region + CloudFront | ~$300 |
| **DynamoDB** | Global Tables + High throughput | ~$500 |
| **Redis** | cache.r6g.4xlarge cluster (6 shards) | ~$3,800 |
| **Total** | | **~$6,600** |

---

## 🎯 Use Case Scenarios

### E-Commerce Platform

```hcl
# Product catalog in PostgreSQL
module "products_db" {
  source = ".../rds-postgres-database"
  # Configuration for transactional data
}

# Session management in DynamoDB
module "sessions" {
  source = ".../dynamodb-nosql-table"
  # Fast, scalable session storage
}

# Cache layer with Redis
module "cache" {
  source = ".../elasticache-redis"
  # Product catalog caching
}

# Static assets in S3
module "assets" {
  source = ".../s3-static-website"
  # Product images, CSS, JS
}
```

### SaaS Application

```hcl
# User data in PostgreSQL
module "user_db" {
  source = ".../rds-postgres-database"
}

# Real-time features in DynamoDB
module "realtime_data" {
  source = ".../dynamodb-nosql-table"
  enable_streams = true  # For triggers
}

# Application cache
module "app_cache" {
  source = ".../elasticache-redis"
  cluster_mode_enabled = true
}
```

### Content Management System

```hcl
# Content in PostgreSQL
module "content_db" {
  source = ".../rds-postgres-database"
}

# Media files in S3
module "media" {
  source = ".../s3-static-website"
  enable_cloudfront = true
}

# CDN cache
module "cdn_cache" {
  source = ".../elasticache-redis"
}
```

---

## 🔒 Security Best Practices

### RDS PostgreSQL
- ✅ Enable encryption at rest (KMS)
- ✅ Enable encryption in transit (SSL)
- ✅ Store credentials in Secrets Manager
- ✅ Use IAM database authentication
- ✅ Deploy in private subnets
- ✅ Enable Enhanced Monitoring
- ✅ Configure automated backups (7-35 days)

### DynamoDB
- ✅ Enable point-in-time recovery
- ✅ Use encryption at rest
- ✅ Implement least-privilege IAM policies
- ✅ Enable deletion protection
- ✅ Use VPC endpoints for private access
- ✅ Monitor with CloudWatch alarms

### ElastiCache Redis
- ✅ Enable encryption at rest and in transit
- ✅ Use AUTH tokens
- ✅ Deploy in private subnets
- ✅ Restrict security group access
- ✅ Enable automatic failover
- ✅ Configure automated snapshots

### S3
- ✅ Block public access (unless needed)
- ✅ Enable versioning
- ✅ Use CloudFront for public content
- ✅ Enable access logging
- ✅ Implement lifecycle policies
- ✅ Use encryption (S3-managed or KMS)

---

## 🎓 Pro Version Features

Upgrade to **Pro/Enterprise** tier for advanced capabilities:

| Feature | Free | Pro | Enterprise |
|---------|------|-----|------------|
| **RDS Proxy** | ❌ | ✅ | ✅ |
| **DynamoDB DAX** | ❌ | ✅ | ✅ |
| **Redis Global Datastore** | ❌ | ✅ | ✅ |
| **S3 Intelligent Tiering** | ✅ | ✅ | ✅ |
| **Multi-Region Replication** | ❌ | ✅ | ✅ |
| **Automated Disaster Recovery** | ❌ | ✅ | ✅ |
| **Cost Optimization Advisor** | ❌ | ✅ | ✅ |
| **24/7 Support** | ❌ | ❌ | ✅ |
| **Custom SLA (99.99%)** | ❌ | ❌ | ✅ |

**[Contact Sales](mailto:sales@example.com)** for Pro/Enterprise pricing.

---

## 📚 Related Modules

- **[Networking](../networking/)** - VPC, Subnets, Security Groups
- **[Compute](../compute/)** - ECS, Lambda, EC2
- **[Security & IAM](../security-iam/)** - KMS, Secrets Manager, IAM Roles
- **[Monitoring & Ops](../monitoring-ops/)** - CloudWatch, Backups

---

## 🤝 Contributing

Contributions welcome! See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.

---

## 📄 License

MIT License - See [LICENSE](../LICENSE) for details.

---

## 💬 Support

- 📧 **Community**: [GitHub Issues](https://github.com/yourusername/aws-startup-terraform-modules/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/yourusername/aws-startup-terraform-modules/discussions)
- 📖 **Docs**: [Full Documentation](https://github.com/yourusername/aws-startup-terraform-modules)
- 🎓 **Pro Support**: [Contact Sales](mailto:sales@example.com)

---

**Made with ❤️ by the AWS Startup Terraform Modules team**
