# Complete Startup Infrastructure Example

**Full production-ready environment using aws-startup-terraform-modules.**

This example demonstrates how to deploy a complete startup infrastructure including:
- Multi-AZ VPC with public/private/database subnets
- Application Load Balancer with SSL/TLS
- ECS Fargate services (backend API + frontend web)
- Lambda functions for serverless processing
- RDS PostgreSQL database
- Secrets Manager for credential management
- CloudWatch monitoring and alerting
- Route53 DNS configuration

---

## 🏗️ Architecture

```
Internet
   ↓
[Route53] → app.example.com
   ↓
[Application Load Balancer]
   ↓ (SSL Termination)
┌──────────┴──────────┐
│      VPC            │
│  ┌───────────────┐  │
│  │ Public Subnet │  │
│  │   NAT Gateway │  │
│  └───────┬───────┘  │
│          ↓          │
│  ┌───────────────┐  │
│  │ Private Subnet│  │
│  │               │  │
│  │ ECS Fargate:  │  │
│  │ - Backend API │  │
│  │ - Frontend    │  │
│  │               │  │
│  │ Lambda:       │  │
│  │ - Processors  │  │
│  └───────┬───────┘  │
│          ↓          │
│  ┌───────────────┐  │
│  │Database Subnet│  │
│  │ RDS PostgreSQL│  │
│  └───────────────┘  │
└─────────────────────┘
```

---

## 🚀 Quick Start

### Prerequisites

1. **AWS Account** with appropriate permissions
2. **Terraform** >= 1.5.0
3. **AWS CLI** configured
4. **ACM Certificate** for your domain
5. **Container Images** pushed to ECR

### Step 1: Configure Variables

```bash
cp terraform.tfvars production.tfvars
# Edit production.tfvars with your values
```

**Required Variables:**
- `certificate_arn` - Your ACM certificate ARN
- `backend_image` - Your backend Docker image URL
- `frontend_image` - Your frontend Docker image URL
- `domain_name` - Your domain (e.g., app.example.com)
- `alert_emails` - Email addresses for alerts

### Step 2: Initialize Terraform

```bash
terraform init
```

### Step 3: Review Plan

```bash
terraform plan -var-file=production.tfvars
```

### Step 4: Deploy

```bash
terraform apply -var-file=production.tfvars
```

**Deployment Time**: ~15-20 minutes

---

## 📦 What Gets Created

### Networking (5 resources)
- ✅ VPC with 9 subnets (3 public, 3 private, 3 database)
- ✅ 3 NAT Gateways (High Availability)
- ✅ Internet Gateway
- ✅ Application Load Balancer
- ✅ VPC Flow Logs (S3)

### Compute (3 services)
- ✅ ECS Cluster with Container Insights
- ✅ Backend API Service (3 tasks)
- ✅ Frontend Web Service (2 tasks)
- ✅ Lambda Functions for processing

### Database (1 instance)
- ✅ RDS PostgreSQL (Multi-AZ in production)
- ✅ Automated backups
- ✅ Performance Insights

### Security (5 resources)
- ✅ Security Groups (ALB, ECS, RDS)
- ✅ IAM Roles (ECS task & execution)
- ✅ Secrets Manager (DB password, JWT secret)
- ✅ Encryption (at rest and in transit)

### Monitoring (3 resources)
- ✅ CloudWatch Dashboard
- ✅ SNS Topic for alerts
- ✅ CloudWatch Log Groups

---

## 💰 Cost Estimation

### Production Environment (~$400-550/month)

| Resource | Configuration | Monthly Cost |
|----------|---------------|--------------|
| VPC & NAT Gateways | 3 NAT GW | ~$100 |
| Application Load Balancer | 1 ALB | ~$25 |
| ECS Fargate | 5 tasks (1 vCPU, 2 GB) | ~$150-300 |
| RDS PostgreSQL | db.t4g.medium Multi-AZ | ~$100 |
| CloudWatch Logs | 50 GB/month | ~$20 |
| Secrets Manager | 2 secrets | ~$1 |
| Route53 | 1 hosted zone | ~$0.50 |
| **Total** | | **~$396-546/month** |

### Dev/Staging Environment (~$150-200/month)

| Resource | Configuration | Monthly Cost |
|----------|---------------|--------------|
| VPC & NAT Gateway | 1 NAT GW | ~$35 |
| Application Load Balancer | 1 ALB | ~$25 |
| ECS Fargate | 3 tasks (0.5 vCPU, 1 GB) | ~$60-100 |
| RDS PostgreSQL | db.t4g.micro | ~$15 |
| CloudWatch Logs | 10 GB/month | ~$10 |
| **Total** | | **~$145-185/month** |

### Cost Optimization Tips

1. **Enable Fargate Spot**: Set `enable_fargate_spot = true` for 70% savings
2. **Single NAT Gateway**: Use for non-production (`single_nat_gateway = true`)
3. **Right-Size RDS**: Start with `db.t4g.micro` for dev
4. **Log Retention**: Reduce to 7 days for dev environments
5. **Auto-Scaling**: Reduces costs during low-traffic periods

---

## 🔒 Security Features

### Network Security
- ✅ **Private Subnets**: All compute in private subnets
- ✅ **Security Groups**: Restrictive ingress rules
- ✅ **VPC Flow Logs**: Network traffic monitoring
- ✅ **No Public IPs**: For ECS tasks and RDS

### Data Security
- ✅ **Encryption at Rest**: RDS, EBS, S3
- ✅ **Encryption in Transit**: SSL/TLS, HTTPS
- ✅ **Secrets Management**: AWS Secrets Manager
- ✅ **IAM Least Privilege**: Minimal permissions

### Compliance
- ✅ **SOC 2**: Audit logs via VPC Flow Logs
- ✅ **HIPAA**: Encryption and network isolation
- ✅ **PCI-DSS**: Secure network architecture

---

## 📊 Monitoring & Operations

### CloudWatch Dashboard

View real-time metrics:
```bash
# Get dashboard URL
terraform output cloudwatch_dashboard_url
```

**Metrics Included:**
- ALB request count and latency
- ECS CPU and memory utilization
- RDS connections and performance
- Lambda invocations and errors

### Email Alerts

Configure in `terraform.tfvars`:
```hcl
alert_emails = [
  "devops@example.com",
  "oncall@example.com"
]
```

**Alerts for:**
- High ALB error rates (5XX)
- ECS service health issues
- RDS high CPU/memory
- Lambda function errors

### Logs

Access application logs:
```bash
# Backend API logs
aws logs tail /ecs/my-startup-cluster/backend-api --follow

# Frontend logs
aws logs tail /ecs/my-startup-cluster/frontend-web --follow
```

---

## 🔧 Operations

### Deploying New Code

```bash
# Build and push new Docker image
docker build -t backend-api:v1.2.0 .
docker tag backend-api:v1.2.0 123456789012.dkr.ecr.us-east-1.amazonaws.com/backend-api:v1.2.0
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/backend-api:v1.2.0

# Update service (ECS will perform rolling update)
aws ecs update-service \
  --cluster my-startup-cluster \
  --service backend-api \
  --force-new-deployment
```

### Scaling Services

```hcl
# In terraform.tfvars, adjust:
desired_count = 5  # Scale to 5 tasks

# Apply changes
terraform apply -var-file=production.tfvars
```

### Database Backups

```bash
# Manual snapshot
aws rds create-db-snapshot \
  --db-instance-identifier my-startup-db \
  --db-snapshot-identifier manual-backup-2025-10-31

# List backups
aws rds describe-db-snapshots \
  --db-instance-identifier my-startup-db
```

### Disaster Recovery

```bash
# Restore from snapshot
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier my-startup-db-restored \
  --db-snapshot-identifier automated-backup-2025-10-31
```

---

## 🧪 Testing

### Health Checks

```bash
# ALB health
curl https://app.example.com/health

# Backend API
curl https://app.example.com/api/health

# Database connectivity
aws rds describe-db-instances \
  --db-instance-identifier my-startup-db \
  --query 'DBInstances[0].DBInstanceStatus'
```

### Load Testing

```bash
# Install hey
go install github.com/rakyll/hey@latest

# Run load test
hey -n 10000 -c 100 https://app.example.com/
```

---

## 🔄 Updating Infrastructure

### Minor Updates

```bash
# Update a specific module
terraform apply -target=module.backend_api -var-file=production.tfvars
```

### Major Updates

```bash
# Always plan first
terraform plan -var-file=production.tfvars -out=tfplan

# Review carefully
terraform show tfplan

# Apply
terraform apply tfplan
```

---

## 🗑️ Cleanup

**Warning**: This destroys all resources!

```bash
# Disable deletion protection
terraform apply -var="enable_deletion_protection=false" -var-file=production.tfvars

# Destroy
terraform destroy -var-file=production.tfvars
```

---

## 📚 Additional Resources

- [Module Documentation](../../README.md)
- [VPC Networking](../../networking/vpc-networking/README.md)
- [ECS Fargate Service](../../compute/ecs-fargate-service/README.md)
- [ALB Load Balancer](../../networking/alb-loadbalancer/README.md)

---

## 🐛 Troubleshooting

### ECS Tasks Not Starting

```bash
# Check service events
aws ecs describe-services \
  --cluster my-startup-cluster \
  --services backend-api \
  --query 'services[0].events[0:5]'

# Check task logs
aws logs tail /ecs/my-startup-cluster/backend-api --since 1h
```

### Database Connection Issues

```bash
# Test from ECS task
aws ecs execute-command \
  --cluster my-startup-cluster \
  --task <task-id> \
  --container backend-api \
  --interactive \
  --command "/bin/bash"

# Inside container
nc -zv $DATABASE_HOST 5432
```

### High Costs

```bash
# Check cost explorer
aws ce get-cost-and-usage \
  --time-period Start=2025-10-01,End=2025-10-31 \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --group-by Type=SERVICE
```

---

## 💬 Support

- **GitHub Issues**: [Report a bug](https://github.com/Sumanth12-afk/aws-startup-terraform-modules/issues)
- **Discussions**: [Ask a question](https://github.com/Sumanth12-afk/aws-startup-terraform-modules/discussions)
- **Email**: support@example.com

---

**Built with ❤️ using aws-startup-terraform-modules**

