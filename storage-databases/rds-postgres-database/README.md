# RDS PostgreSQL Database Module

[![Terraform](https://img.shields.io/badge/Terraform-1.5+-623CE4?logo=terraform)](https://www.terraform.io/)
[![AWS Provider](https://img.shields.io/badge/AWS-5.0+-FF9900?logo=amazon-aws)](https://registry.terraform.io/providers/hashicorp/aws/latest)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](../LICENSE)

## Overview

Production-ready AWS RDS PostgreSQL database module with enterprise features including Multi-AZ deployment, automated backups, encryption at rest and in transit, performance insights, enhanced monitoring, and secure credential management via AWS Secrets Manager.

### Key Features

- ✅ **High Availability**: Multi-AZ deployment with automatic failover
- ✅ **Security**: Encryption at rest (KMS), encryption in transit (SSL), IAM authentication
- ✅ **Monitoring**: Performance Insights, Enhanced Monitoring, CloudWatch alarms
- ✅ **Backup & Recovery**: Automated backups, point-in-time recovery, manual snapshots
- ✅ **Compliance**: Deletion protection, audit logging, encryption enforcement
- ✅ **Scalability**: Read replicas support, automated storage scaling
- ✅ **Cost Optimization**: Storage auto-scaling, right-sized instance classes

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         VPC (10.0.0.0/16)                       │
│                                                                 │
│  ┌─────────────────┐              ┌─────────────────┐          │
│  │  Private Subnet │              │  Private Subnet │          │
│  │   (AZ: us-e-1a) │              │   (AZ: us-e-1b) │          │
│  │                 │              │                 │          │
│  │  ┌───────────┐  │              │  ┌───────────┐  │          │
│  │  │           │  │              │  │           │  │          │
│  │  │   RDS     │◄─┼──────────────┼─►│   RDS     │  │          │
│  │  │ Primary   │  │  Multi-AZ    │  │ Standby   │  │          │
│  │  │ Instance  │  │  Replication │  │ Instance  │  │          │
│  │  │           │  │              │  │           │  │          │
│  │  └─────┬─────┘  │              │  └───────────┘  │          │
│  │        │        │              │                 │          │
│  └────────┼────────┘              └─────────────────┘          │
│           │                                                     │
│           │  ┌────────────────────────────────────┐            │
│           └─►│     DB Subnet Group                │            │
│              │  (Spans Multiple AZs)              │            │
│              └────────────────────────────────────┘            │
│                                                                 │
│  ┌───────────────────────────────────────────────────────┐    │
│  │              Security Group                           │    │
│  │  • Ingress: Port 5432 from allowed CIDR blocks       │    │
│  │  • Egress: All traffic                               │    │
│  └───────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────┐
│                     AWS Services Integration                    │
│                                                                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │ AWS Secrets  │  │  AWS KMS     │  │  CloudWatch  │        │
│  │   Manager    │  │  Encryption  │  │  Monitoring  │        │
│  │ (Credentials)│  │  (Storage)   │  │  (Metrics)   │        │
│  └──────────────┘  └──────────────┘  └──────────────┘        │
│                                                                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │ Performance  │  │  Enhanced    │  │  Automated   │        │
│  │   Insights   │  │  Monitoring  │  │   Backups    │        │
│  │  (Query DB)  │  │   (IAM Role) │  │  (S3 Storage)│        │
│  └──────────────┘  └──────────────┘  └──────────────┘        │
└────────────────────────────────────────────────────────────────┘
```

---

## Usage Example

### Basic Usage

```hcl
module "rds_postgres" {
  source = "github.com/yourusername/aws-startup-terraform-modules//storage-databases/rds-postgres-database?ref=v1.0.0"

  # Environment
  environment = "production"
  aws_region  = "us-east-1"

  # Database Configuration
  db_name     = "myapp"
  db_username = "dbadmin"

  # Network
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnet_ids
  allowed_cidr_blocks = [module.vpc.vpc_cidr]

  # Instance
  instance_class    = "db.t4g.medium"
  allocated_storage = 100

  # High Availability
  multi_az                = true
  backup_retention_period = 7

  tags = {
    Project = "MyApp"
    Owner   = "DevOps"
  }
}
```

### Production Configuration with Advanced Features

```hcl
module "rds_postgres_prod" {
  source = "github.com/yourusername/aws-startup-terraform-modules//storage-databases/rds-postgres-database?ref=v1.0.0"

  # Environment
  environment = "production"
  aws_region  = "us-east-1"

  # Remote State
  state_bucket_name = "my-terraform-state"
  state_lock_table  = "terraform-locks"

  # Database
  db_name         = "production_db"
  db_username     = "prod_admin"
  engine_version  = "15.3"
  db_port         = 5432

  # Instance Configuration
  instance_class         = "db.r6g.xlarge"
  allocated_storage      = 500
  max_allocated_storage  = 2000  # Auto-scaling up to 2TB
  storage_type           = "gp3"
  iops                   = 12000
  storage_throughput     = 500

  # Network
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.database_subnet_ids
  allowed_cidr_blocks = [
    module.vpc.private_subnet_cidr_blocks,
    module.vpc.app_subnet_cidr_blocks
  ]

  # High Availability & Disaster Recovery
  multi_az                   = true
  backup_retention_period    = 30
  backup_window              = "03:00-04:00"
  maintenance_window         = "sun:04:00-sun:05:00"
  delete_automated_backups   = false
  copy_tags_to_snapshot      = true
  skip_final_snapshot        = false
  final_snapshot_identifier  = "prod-db-final-snapshot"

  # Security
  deletion_protection          = true
  iam_database_authentication  = true
  kms_key_id                   = module.kms.key_arn
  enable_cloudwatch_logs       = true
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  # Monitoring
  enable_performance_insights          = true
  performance_insights_retention_period = 731  # 2 years
  enable_enhanced_monitoring           = true
  monitoring_interval                  = 30

  # Performance
  auto_minor_version_upgrade = false
  apply_immediately          = false
  parameter_group_family     = "postgres15"

  # Custom Parameters
  db_parameters = [
    {
      name  = "shared_preload_libraries"
      value = "pg_stat_statements,auto_explain"
    },
    {
      name  = "log_min_duration_statement"
      value = "1000"  # Log queries taking >1s
    },
    {
      name  = "max_connections"
      value = "500"
    }
  ]

  # Tags
  tags = {
    Project     = "MyApp"
    Environment = "production"
    Owner       = "DevOps Team"
    CostCenter  = "Engineering"
    Compliance  = "HIPAA"
    Backup      = "Required"
  }
}

# Create read replica for reporting workloads
module "rds_read_replica" {
  source = "github.com/yourusername/aws-startup-terraform-modules//storage-databases/rds-postgres-database?ref=v1.0.0"

  environment = "production"
  aws_region  = "us-east-1"

  # Replica Configuration
  replicate_source_db = module.rds_postgres_prod.db_instance_id
  instance_class      = "db.r6g.large"

  # Performance
  enable_performance_insights = true
  
  tags = {
    Project = "MyApp"
    Role    = "ReadReplica"
  }
}
```

---

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `environment` | Environment name (e.g., dev, staging, production) | `string` | n/a | yes |
| `aws_region` | AWS region where resources will be created | `string` | `"us-east-1"` | no |
| `aws_profile` | AWS CLI profile to use | `string` | `"default"` | no |
| `state_bucket_name` | S3 bucket name for Terraform state | `string` | `""` | no |
| `state_lock_table` | DynamoDB table name for state locking | `string` | `""` | no |
| `db_name` | Name of the database to create | `string` | n/a | yes |
| `db_username` | Master username for the database | `string` | `"dbadmin"` | no |
| `db_port` | Database port | `number` | `5432` | no |
| `instance_class` | Database instance type | `string` | `"db.t4g.medium"` | no |
| `allocated_storage` | Initial storage allocation in GB | `number` | `100` | no |
| `max_allocated_storage` | Maximum storage for auto-scaling (0 = disabled) | `number` | `0` | no |
| `storage_type` | Storage type (gp2, gp3, io1, io2) | `string` | `"gp3"` | no |
| `iops` | Provisioned IOPS (required for io1/io2) | `number` | `null` | no |
| `storage_throughput` | Storage throughput in MB/s (gp3 only) | `number` | `null` | no |
| `engine_version` | PostgreSQL engine version | `string` | `"15.3"` | no |
| `vpc_id` | VPC ID where RDS will be deployed | `string` | n/a | yes |
| `subnet_ids` | List of subnet IDs for DB subnet group | `list(string)` | n/a | yes |
| `allowed_cidr_blocks` | CIDR blocks allowed to connect | `list(string)` | `[]` | no |
| `allowed_security_group_ids` | Security group IDs allowed to connect | `list(string)` | `[]` | no |
| `multi_az` | Enable Multi-AZ deployment | `bool` | `true` | no |
| `backup_retention_period` | Backup retention in days (0-35) | `number` | `7` | no |
| `backup_window` | Daily backup window (UTC) | `string` | `"03:00-04:00"` | no |
| `maintenance_window` | Weekly maintenance window (UTC) | `string` | `"sun:04:00-sun:05:00"` | no |
| `deletion_protection` | Enable deletion protection | `bool` | `true` | no |
| `skip_final_snapshot` | Skip final snapshot on deletion | `bool` | `false` | no |
| `final_snapshot_identifier` | Name of final snapshot | `string` | `null` | no |
| `iam_database_authentication` | Enable IAM database authentication | `bool` | `false` | no |
| `kms_key_id` | KMS key ARN for encryption | `string` | `null` | no |
| `enable_performance_insights` | Enable Performance Insights | `bool` | `true` | no |
| `performance_insights_retention_period` | Performance Insights retention (days) | `number` | `7` | no |
| `enable_enhanced_monitoring` | Enable Enhanced Monitoring | `bool` | `true` | no |
| `monitoring_interval` | Enhanced monitoring interval (0,1,5,10,15,30,60) | `number` | `60` | no |
| `enable_cloudwatch_logs` | Enable CloudWatch log exports | `bool` | `true` | no |
| `enabled_cloudwatch_logs_exports` | Log types to export | `list(string)` | `["postgresql", "upgrade"]` | no |
| `auto_minor_version_upgrade` | Enable automatic minor version upgrades | `bool` | `true` | no |
| `apply_immediately` | Apply changes immediately | `bool` | `false` | no |
| `parameter_group_family` | DB parameter group family | `string` | `"postgres15"` | no |
| `db_parameters` | Custom database parameters | `list(object)` | `[]` | no |
| `publicly_accessible` | Make database publicly accessible | `bool` | `false` | no |
| `replicate_source_db` | Source DB identifier for read replica | `string` | `null` | no |
| `tags` | Additional tags for all resources | `map(string)` | `{}` | no |

---

## Outputs

| Name | Description |
|------|-------------|
| `db_instance_id` | RDS instance identifier |
| `db_instance_arn` | RDS instance ARN |
| `db_instance_endpoint` | Connection endpoint (host:port) |
| `db_instance_address` | Hostname of the RDS instance |
| `db_instance_hosted_zone_id` | Route53 hosted zone ID |
| `db_port` | Database port |
| `db_name` | Database name |
| `db_username` | Master username |
| `db_secret_arn` | ARN of Secrets Manager secret containing credentials |
| `db_secret_name` | Name of Secrets Manager secret |
| `db_subnet_group_id` | DB subnet group ID |
| `db_subnet_group_arn` | DB subnet group ARN |
| `db_parameter_group_id` | DB parameter group ID |
| `db_parameter_group_arn` | DB parameter group ARN |
| `db_security_group_id` | Security group ID |
| `db_security_group_arn` | Security group ARN |
| `enhanced_monitoring_role_arn` | IAM role ARN for enhanced monitoring |
| `kms_key_id` | KMS key ID used for encryption |
| `performance_insights_enabled` | Whether Performance Insights is enabled |
| `cloudwatch_log_groups` | List of CloudWatch log group names |

---

## Security Considerations

### 🔒 Encryption

- **At Rest**: Automatically enabled with customer-managed KMS key
- **In Transit**: SSL/TLS enforced for all connections
- **Secrets**: Credentials stored in AWS Secrets Manager with automatic rotation

### 🔐 Access Control

- **Network**: Deployed in private subnets with security groups
- **IAM**: Optional IAM database authentication for passwordless access
- **Least Privilege**: Security groups restrict access to specified CIDR blocks

### 📊 Monitoring & Auditing

- **Performance Insights**: Query-level performance monitoring
- **Enhanced Monitoring**: OS-level metrics (CPU, memory, I/O)
- **CloudWatch Logs**: PostgreSQL logs exported for analysis
- **Audit Logging**: Enable pgAudit for compliance requirements

### 🛡️ Compliance

- **Deletion Protection**: Prevents accidental database deletion
- **Automated Backups**: 7-30 day retention with point-in-time recovery
- **Final Snapshots**: Required before deletion
- **Multi-AZ**: High availability with automatic failover

---

## Cost Optimization

### 💰 Estimated Monthly Costs

| Configuration | Instance | Storage | Backups | Total/Month |
|---------------|----------|---------|---------|-------------|
| **Dev/Test** | db.t4g.medium | 100GB gp3 | 7 days | ~$150 |
| **Staging** | db.r6g.large | 250GB gp3 | 14 days | ~$400 |
| **Production** | db.r6g.xlarge | 500GB gp3 | 30 days | ~$800 |
| **Enterprise** | db.r6g.2xlarge | 1TB gp3 + Read Replica | 30 days | ~$2,000 |

### 💡 Cost Saving Tips

1. **Right-Size Instances**: Start with smaller instances, scale up as needed
2. **Storage Auto-Scaling**: Use `max_allocated_storage` instead of over-provisioning
3. **Reserved Instances**: 40-60% savings with 1-3 year commitments
4. **Dev/Test Licensing**: Use smaller instances for non-production
5. **Snapshot Lifecycle**: Delete old snapshots beyond retention period
6. **Multi-AZ**: Consider single-AZ for dev/test environments

---

## Pro Version Features

Upgrade to **Pro/Enterprise tier** for advanced capabilities:

| Feature | Free | Pro | Enterprise |
|---------|------|-----|------------|
| **Multi-Region Replication** | ❌ | ✅ | ✅ |
| **Automated Failover Testing** | ❌ | ✅ | ✅ |
| **Query Performance Analyzer** | ❌ | ✅ | ✅ |
| **Cost Anomaly Detection** | ❌ | ✅ | ✅ |
| **Custom Backup Strategies** | ❌ | ✅ | ✅ |
| **Database Proxy (RDS Proxy)** | ❌ | ✅ | ✅ |
| **Blue/Green Deployments** | ❌ | ❌ | ✅ |
| **Automated Security Patching** | ❌ | ❌ | ✅ |
| **24/7 Support** | ❌ | ❌ | ✅ |
| **Custom SLA (99.99% uptime)** | ❌ | ❌ | ✅ |

**[Contact Sales](mailto:sales@example.com)** for Pro/Enterprise pricing.

---

## Common Use Cases

### 1. **Web Application Backend**
```hcl
# Production web app with high availability
instance_class    = "db.r6g.large"
multi_az          = true
allocated_storage = 250
```

### 2. **Analytics Workload**
```hcl
# Read-heavy analytics with read replica
instance_class         = "db.r6g.2xlarge"
max_allocated_storage  = 2000
replicate_source_db    = aws_db_instance.primary.id
```

### 3. **Microservices Backend**
```hcl
# Multiple small databases for microservices
instance_class    = "db.t4g.medium"
allocated_storage = 50
backup_retention  = 7
```

### 4. **HIPAA/Compliance Workload**
```hcl
# Encryption, auditing, and long retention
deletion_protection        = true
kms_key_id                = module.kms.key_arn
backup_retention_period   = 35
enable_cloudwatch_logs    = true
iam_database_authentication = true
```

---

## Troubleshooting

### Connection Issues

```bash
# Test connectivity from application server
psql -h <endpoint> -U <username> -d <database> -p 5432

# Check security group rules
aws ec2 describe-security-groups --group-ids <sg-id>

# Verify DNS resolution
nslookup <rds-endpoint>
```

### Performance Issues

```bash
# Check CloudWatch metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name CPUUtilization \
  --dimensions Name=DBInstanceIdentifier,Value=<instance-id>

# Query Performance Insights
aws pi get-resource-metrics \
  --service-type RDS \
  --identifier <db-resource-id>
```

### Credential Rotation

```bash
# Retrieve credentials from Secrets Manager
aws secretsmanager get-secret-value \
  --secret-id <secret-arn> \
  --query SecretString \
  --output text | jq -r '.password'
```

---

## Related Modules

- **[S3 Static Website](../s3-static-website/)** - Store database backups
- **[Lambda API Gateway](../../compute/lambda-api-gateway/)** - Serverless database access
- **[VPC Networking](../../networking/vpc-networking/)** - Network foundation
- **[Secrets Manager](../../security-iam/secrets-manager/)** - Credential management

---

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](../../CONTRIBUTING.md) for details.

---

## License

This module is licensed under the MIT License. See [LICENSE](LICENSE) for full details.

---

## Support

- 📧 **Community Support**: [GitHub Issues](https://github.com/yourusername/aws-startup-terraform-modules/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/yourusername/aws-startup-terraform-modules/discussions)
- 📖 **Documentation**: [Full Documentation](https://github.com/yourusername/aws-startup-terraform-modules)
- 🎓 **Pro Support**: [Contact Sales](mailto:sales@example.com)

---

**Made with ❤️ by the AWS Startup Terraform Modules team**

