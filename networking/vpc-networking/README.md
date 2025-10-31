# VPC Networking Module

**Production-ready, multi-AZ VPC with public/private/database subnets, NAT Gateways, and VPC Flow Logs.**

This Terraform module creates a complete AWS VPC infrastructure following AWS Well-Architected Framework best practices. It provides a secure, scalable foundation for deploying applications with proper network segmentation, high availability, and comprehensive monitoring.

---

## 📋 Features

✅ **Multi-AZ Architecture**: Subnets across multiple availability zones for high availability  
✅ **Three-Tier Network**: Public, private, and isolated database subnets  
✅ **NAT Gateway**: Managed NAT Gateways for private subnet internet access  
✅ **VPC Flow Logs**: Network traffic logging to S3 or CloudWatch Logs  
✅ **IPv6 Support**: Optional IPv6 addressing  
✅ **Custom DHCP Options**: Configurable DNS and domain settings  
✅ **Encryption**: S3 Flow Logs encrypted by default  
✅ **Cost Optimization**: Option for single NAT Gateway in non-production environments  
✅ **Auto-Tagging**: Consistent resource tagging for cost allocation and management  

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         AWS Region                              │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              VPC (10.0.0.0/16)                           │  │
│  │                                                          │  │
│  │  Availability Zone 1         Availability Zone 2         │  │
│  │  ┌────────────────────┐      ┌────────────────────┐     │  │
│  │  │ Public Subnet      │      │ Public Subnet      │     │  │
│  │  │ 10.0.0.0/24        │      │ 10.0.1.0/24        │     │  │
│  │  │ - ALB              │      │ - ALB              │     │  │
│  │  │ - NAT Gateway      │      │ - NAT Gateway      │     │  │
│  │  └────────────────────┘      └────────────────────┘     │  │
│  │           ↕                           ↕                  │  │
│  │  ┌────────────────────┐      ┌────────────────────┐     │  │
│  │  │ Private Subnet     │      │ Private Subnet     │     │  │
│  │  │ 10.0.10.0/24       │      │ 10.0.11.0/24       │     │  │
│  │  │ - EC2/ECS          │      │ - EC2/ECS          │     │  │
│  │  │ - Lambda (VPC)     │      │ - Lambda (VPC)     │     │  │
│  │  └────────────────────┘      └────────────────────┘     │  │
│  │           ↕                           ↕                  │  │
│  │  ┌────────────────────┐      ┌────────────────────┐     │  │
│  │  │ Database Subnet    │      │ Database Subnet    │     │  │
│  │  │ 10.0.20.0/24       │      │ 10.0.21.0/24       │     │  │
│  │  │ - RDS              │      │ - RDS (Replica)    │     │  │
│  │  │ - ElastiCache      │      │ - ElastiCache      │     │  │
│  │  └────────────────────┘      └────────────────────┘     │  │
│  │                                                          │  │
│  │  [Internet Gateway]  [VPC Flow Logs → S3]               │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### Subnet Strategy

- **Public Subnets**: Internet-facing resources (ALB, NAT Gateway, Bastion)
- **Private Subnets**: Application workloads (EC2, ECS, EKS, Lambda)
- **Database Subnets**: Data tier (RDS, ElastiCache, Redshift) - No direct internet access

---

## 🚀 Usage

### Basic Example

```hcl
module "vpc" {
  source = "your-org/vpc-networking/aws"
  version = "~> 1.0"

  environment        = "production"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

  tags = {
    Project = "my-startup"
    Team    = "platform"
  }
}
```

### Production Configuration

```hcl
module "vpc_production" {
  source = "your-org/vpc-networking/aws"
  version = "~> 1.0"

  environment        = "production"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

  # High Availability
  enable_nat_gateway      = true
  single_nat_gateway      = false  # NAT Gateway per AZ

  # Database Tier
  enable_database_subnets = true

  # Monitoring & Security
  enable_flow_logs           = true
  flow_logs_destination_type = "s3"
  flow_logs_traffic_type     = "ALL"
  flow_logs_retention_days   = 90

  # DNS
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Project     = "my-startup"
    Team        = "platform"
    Environment = "production"
    CostCenter  = "engineering"
    Compliance  = "pci-dss"
  }
}

# Access outputs
output "vpc_id" {
  value = module.vpc_production.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc_production.private_subnet_ids
}
```

### Cost-Optimized Development Environment

```hcl
module "vpc_dev" {
  source = "your-org/vpc-networking/aws"
  version = "~> 1.0"

  environment        = "dev"
  vpc_cidr           = "10.1.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]

  # Cost Optimization
  enable_nat_gateway      = true
  single_nat_gateway      = true   # Single NAT saves ~$64/month
  enable_database_subnets = false  # Use RDS in private subnets
  enable_flow_logs        = false  # Disable for dev to save costs

  tags = {
    Project     = "my-startup"
    Team        = "platform"
    Environment = "dev"
  }
}
```

---

## 📥 Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name (dev, staging, production) | `string` | n/a | yes |
| vpc_cidr | CIDR block for the VPC | `string` | `"10.0.0.0/16"` | no |
| availability_zones | List of availability zones (min 2 for HA) | `list(string)` | n/a | yes |
| subnet_cidr_newbits | Additional bits for subnet CIDR calculation | `number` | `8` | no |
| enable_dns_hostnames | Enable DNS hostnames in VPC | `bool` | `true` | no |
| enable_dns_support | Enable DNS support in VPC | `bool` | `true` | no |
| enable_ipv6 | Enable IPv6 support | `bool` | `false` | no |
| enable_nat_gateway | Enable NAT Gateway for private subnets | `bool` | `true` | no |
| single_nat_gateway | Use single NAT Gateway (cost optimization) | `bool` | `false` | no |
| enable_database_subnets | Create dedicated database subnets | `bool` | `true` | no |
| enable_flow_logs | Enable VPC Flow Logs | `bool` | `true` | no |
| flow_logs_destination_type | Destination for flow logs (s3, cloud-watch-logs) | `string` | `"s3"` | no |
| flow_logs_traffic_type | Traffic type to capture (ACCEPT, REJECT, ALL) | `string` | `"ALL"` | no |
| flow_logs_retention_days | Flow logs retention period in days | `number` | `90` | no |
| enable_custom_dhcp_options | Enable custom DHCP options | `bool` | `false` | no |
| dhcp_options_domain_name | Domain name for DHCP options | `string` | `""` | no |
| dhcp_options_domain_name_servers | DNS servers for DHCP options | `list(string)` | `["AmazonProvidedDNS"]` | no |
| tags | Additional tags for all resources | `map(string)` | `{}` | no |

---

## 📤 Outputs

| Name | Description |
|------|-------------|
| vpc_id | ID of the VPC |
| vpc_cidr | CIDR block of the VPC |
| vpc_arn | ARN of the VPC |
| internet_gateway_id | ID of the Internet Gateway |
| public_subnet_ids | List of public subnet IDs |
| public_subnet_cidrs | List of public subnet CIDR blocks |
| public_route_table_id | ID of the public route table |
| private_subnet_ids | List of private subnet IDs |
| private_subnet_cidrs | List of private subnet CIDR blocks |
| private_route_table_ids | List of private route table IDs |
| database_subnet_ids | List of database subnet IDs |
| database_subnet_group_name | Name of the DB subnet group |
| nat_gateway_ids | List of NAT Gateway IDs |
| nat_gateway_public_ips | List of NAT Gateway public IPs |
| flow_logs_s3_bucket | S3 bucket for flow logs |
| availability_zones | List of availability zones used |
| default_security_group_id | ID of the default security group |

---

## 💰 Cost Estimation

### Monthly Costs (us-east-1)

**Production (3 AZs, HA NAT Gateways):**
- VPC: $0 (free)
- Internet Gateway: $0 (free)
- NAT Gateways: 3 × $32.40 = **$97.20**
- Elastic IPs (attached): $0
- VPC Flow Logs (S3): ~**$10-20** (depending on traffic)
- **Total: ~$107-117/month** + data transfer costs

**Development (2 AZs, Single NAT Gateway):**
- NAT Gateway: 1 × $32.40 = **$32.40**
- Flow Logs: $0 (disabled)
- **Total: ~$32.40/month** + data transfer costs

### Cost Optimization Tips

1. **Single NAT Gateway**: Use `single_nat_gateway = true` for non-production (~$65/month savings)
2. **Flow Logs to S3**: More cost-effective than CloudWatch Logs
3. **S3 Lifecycle Policies**: Automatically transition old logs to Glacier
4. **VPC Endpoints**: Reduce NAT Gateway data transfer for AWS services
5. **Right-Size**: Start with 2 AZs, expand to 3+ as traffic grows

---

## 🔒 Security Best Practices

### Built-In Security Features

✅ **Default Security Group Locked Down**: No ingress/egress rules  
✅ **Private Subnets by Default**: Application and database tiers isolated  
✅ **Encrypted Flow Logs**: S3 encryption enabled automatically  
✅ **No Public Database Access**: Database subnets have no route to IGW  
✅ **NAT Gateway**: Prevents inbound internet access to private resources  

### Additional Security Recommendations

```hcl
# Create restrictive security groups
resource "aws_security_group" "app" {
  name        = "app-sg"
  description = "Security group for application tier"
  vpc_id      = module.vpc.vpc_id

  # Allow only from ALB
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Allow outbound HTTPS
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-security-group"
  }
}

# VPC Endpoints for AWS Services (avoid NAT Gateway costs)
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.us-east-1.s3"
  
  route_table_ids = module.vpc.private_route_table_ids

  tags = {
    Name = "s3-vpc-endpoint"
  }
}
```

### Compliance

- **SOC 2**: VPC Flow Logs provide audit trail
- **PCI-DSS**: Network segmentation with isolated database tier
- **HIPAA**: Encrypted logging and private subnet architecture
- **GDPR**: Data residency controls through regional VPC deployment

---

## 📊 Monitoring & Troubleshooting

### VPC Flow Logs Analysis

```bash
# Query Flow Logs in S3 using AWS CLI
aws s3 cp s3://your-flow-logs-bucket/AWSLogs/123456789012/vpcflowlogs/ - --recursive | \
  grep REJECT | \
  awk '{print $3, $4, $5}' | \
  sort | uniq -c | sort -rn | head -20

# Find top talkers
grep ACCEPT flow-logs.txt | \
  awk '{print $3}' | \
  sort | uniq -c | sort -rn | head -10
```

### Common Issues

**Issue**: Instances in private subnets can't reach the internet  
**Solution**: Verify NAT Gateway is deployed and route table association is correct

```bash
# Check NAT Gateway status
terraform output nat_gateway_ids

# Verify route table
aws ec2 describe-route-tables --route-table-ids <rt-id>
```

**Issue**: High NAT Gateway costs  
**Solution**: Implement VPC Endpoints for AWS services

```hcl
# S3 VPC Endpoint (Gateway Endpoint - Free)
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.${var.region}.s3"
  route_table_ids = module.vpc.private_route_table_ids
}

# DynamoDB VPC Endpoint (Gateway Endpoint - Free)
resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.${var.region}.dynamodb"
  route_table_ids = module.vpc.private_route_table_ids
}
```

---

## 🎯 Pro Version Features

**Upgrade to Pro tier ($499/month) for enterprise-grade networking:**

### 🎨 CloudWatch Dashboards
- **Real-Time Network Metrics**: Bandwidth utilization, packet loss, connection counts
- **NAT Gateway Monitoring**: Port allocation, connection tracking, error rates
- **Flow Log Analytics**: Automated anomaly detection and traffic pattern analysis
- **Custom Widgets**: Visualize cross-AZ traffic, top talkers, rejected connections

### 🔐 Advanced Security Baseline
- **AWS Network Firewall**: Stateful inspection, IDS/IPS capabilities
- **GuardDuty VPC Integration**: Automated threat detection for suspicious traffic
- **VPC Traffic Mirroring**: Packet capture for security analysis
- **AWS Config Rules**: Automated compliance checks for VPC configurations
- **Security Hub Integration**: Centralized security findings dashboard

### ⚡ Enhanced Performance
- **VPC Peering Automation**: Multi-VPC connectivity with route table management
- **Transit Gateway Integration**: Hub-and-spoke architecture for multiple VPCs
- **IPv6 Dual-Stack**: Full IPv6 support with egress-only internet gateway
- **Enhanced VPC Routing**: Advanced route propagation and prioritization

### 💰 FinOps Automation
- **Cost Anomaly Detection**: Alert on unexpected NAT Gateway or data transfer charges
- **Right-Sizing Recommendations**: Optimize NAT Gateway placement and quantity
- **Reserved IP Tracking**: Monitor Elastic IP usage and costs
- **Budget Alerts**: Automated Slack/email notifications for cost thresholds
- **Savings Plans**: Guidance on commitment discounts

### 🚀 Advanced Automation
- **Multi-Region Deployment**: Automated VPC creation across regions with peering
- **Disaster Recovery**: Cross-region VPC replication and failover automation
- **CI/CD Integration**: Automated network testing and validation pipelines
- **Infrastructure Drift Detection**: Alert on manual changes outside Terraform
- **Blue/Green Network Updates**: Zero-downtime network migrations

### 📞 Enterprise Support
- **Dedicated Slack Channel**: Direct access to AWS networking experts
- **Architecture Reviews**: Quarterly network design assessments
- **24/7 Incident Support**: 4-hour SLA for critical networking issues
- **Custom Module Development**: Tailored networking modules for unique requirements

---

## 📚 Examples

See the [examples/](examples/) directory for complete working examples:

- **Production HA VPC**: Multi-AZ with NAT per AZ
- **Dev Cost-Optimized**: Single NAT Gateway setup
- **IPv6 Enabled**: Dual-stack networking
- **Custom DHCP**: Corporate DNS integration
- **Minimal VPC**: Testing configuration without NAT

---

## 🔄 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-10 | Initial release with multi-AZ support |
| 1.1.0 | TBD | Add Transit Gateway support |
| 1.2.0 | TBD | Network Firewall integration |

---

## 📝 Requirements

- Terraform >= 1.5.0
- AWS Provider >= 5.0
- AWS Account with VPC creation permissions

---

## 🤝 Contributing

Contributions welcome! Please read [CONTRIBUTING.md](../../CONTRIBUTING.md) for guidelines.

---

## 📄 License

This module is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

---

## 💬 Support

- **Community**: [GitHub Discussions](https://github.com/yourusername/aws-startup-terraform-modules/discussions)
- **Bug Reports**: [GitHub Issues](https://github.com/yourusername/aws-startup-terraform-modules/issues)
- **Pro Support**: support@example.com

---

## 🌟 Related Modules

- [internet-gateway-nat](../internet-gateway-nat/): Standalone NAT Gateway management
- [alb-loadbalancer](../alb-loadbalancer/): Application Load Balancer
- [vpc-peering](../vpc-peering/): VPC Peering connections (Pro version)
- [transit-gateway](../transit-gateway/): Multi-VPC hub architecture (Pro version)

---

**Built with ❤️ for the AWS startup community**

