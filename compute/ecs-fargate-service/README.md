# ECS Fargate Service Module

**Production-ready Amazon ECS Fargate service with auto-scaling, monitoring, and cost optimization.**

Deploy containerized applications on AWS Fargate without managing servers. This module creates a complete ECS Fargate service with integrated load balancing, auto-scaling, CloudWatch logging, and optional Fargate Spot for cost savings.

---

## 📋 Features

✅ **Serverless Containers**: No EC2 instances to manage  
✅ **Auto-Scaling**: CPU and memory-based scaling policies  
✅ **Fargate Spot Support**: Up to 70% cost savings  
✅ **Load Balancer Integration**: ALB/NLB target group attachment  
✅ **Service Discovery**: AWS Cloud Map integration  
✅ **Secrets Management**: Integration with Secrets Manager and SSM  
✅ **CloudWatch Logs**: Centralized container logging  
✅ **ECS Exec**: SSH into containers for debugging  
✅ **Circuit Breaker**: Automatic rollback on deployment failures  
✅ **IAM Roles**: Least-privilege task and execution roles  

---

## 🏗️ Architecture

```
                    Internet
                       ↓
              [Application Load Balancer]
                       ↓
         ┌─────────────┴─────────────┐
         │    ECS Fargate Service    │
         │  (Multiple Availability   │
         │        Zones)             │
         │                           │
         │  ┌─────────┐ ┌─────────┐ │
         │  │ Task 1  │ │ Task 2  │ │
         │  │ (FARGATE)│ │ (SPOT)  │ │
         │  └────┬────┘ └────┬────┘ │
         └───────┼───────────┼──────┘
                 │           │
         ┌───────┴───────────┴──────┐
         │   Secrets Manager / SSM  │
         │   RDS / DynamoDB / S3    │
         │   CloudWatch Logs        │
         └──────────────────────────┘
```

---

## 🚀 Usage

### Prerequisites

1. **VPC with private subnets**
2. **ALB target group** (if using load balancer)
3. **Container image** in ECR or Docker Hub
4. **S3 bucket and DynamoDB table** for Terraform state

### Basic Example

```hcl
module "ecs_service" {
  source = "your-org/ecs-fargate-service/aws"
  version = "~> 1.0"

  # AWS Configuration
  aws_region   = "us-east-1"
  environment  = "production"
  project_name = "my-startup"

  # ECS Configuration
  cluster_name    = "production-cluster"
  service_name    = "api-service"
  desired_count   = 3
  container_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/api:latest"
  container_port  = 8080

  # Resources
  cpu    = 512
  memory = 1024

  # Networking
  vpc_id                     = "vpc-12345678"
  private_subnet_ids         = ["subnet-abc123", "subnet-def456"]
  allowed_security_group_ids = ["sg-alb123"]

  # Load Balancer
  enable_load_balancer = true
  target_group_arn     = "arn:aws:elasticloadbalancing:..."

  # Auto Scaling
  enable_autoscaling = true
  min_capacity       = 2
  max_capacity       = 10
}
```

### With Fargate Spot (Cost Optimization)

```hcl
module "ecs_service_spot" {
  source = "your-org/ecs-fargate-service/aws"
  version = "~> 1.0"

  aws_region      = "us-east-1"
  environment     = "staging"
  cluster_name    = "staging-cluster"
  service_name    = "staging-api"
  container_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/api:staging"
  container_port  = 8080

  # Enable Fargate Spot for 70% savings
  enable_fargate_spot     = true
  fargate_spot_percentage = 70

  cpu    = 256
  memory = 512

  vpc_id                     = "vpc-12345678"
  private_subnet_ids         = ["subnet-abc123", "subnet-def456"]
  allowed_security_group_ids = ["sg-alb123"]
  enable_load_balancer       = true
  target_group_arn           = "arn:aws:elasticloadbalancing:..."
}
```

### With Secrets and Environment Variables

```hcl
module "ecs_service" {
  source = "your-org/ecs-fargate-service/aws"
  version = "~> 1.0"

  aws_region      = "us-east-1"
  environment     = "production"
  cluster_name    = "production-cluster"
  service_name    = "backend-api"
  container_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/backend:v2.0"
  container_port  = 3000

  cpu    = 1024
  memory = 2048

  # Environment Variables
  environment_variables = {
    NODE_ENV   = "production"
    LOG_LEVEL  = "info"
    PORT       = "3000"
    REDIS_HOST = "redis.internal.example.com"
  }

  # Secrets from AWS Secrets Manager
  secrets = [
    {
      name      = "DATABASE_URL"
      valueFrom = "arn:aws:secretsmanager:us-east-1:123456789012:secret:prod/db-url-xxx"
    },
    {
      name      = "API_KEY"
      valueFrom = "arn:aws:ssm:us-east-1:123456789012:parameter/prod/api-key"
    }
  ]

  vpc_id                     = "vpc-12345678"
  private_subnet_ids         = ["subnet-abc123", "subnet-def456"]
  allowed_security_group_ids = ["sg-alb123"]
  enable_load_balancer       = true
  target_group_arn           = "arn:aws:elasticloadbalancing:..."

  enable_autoscaling = true
  min_capacity       = 3
  max_capacity       = 20
}
```

---

## 📥 Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws_region | AWS region | `string` | `"us-east-1"` | no |
| environment | Environment name | `string` | n/a | yes |
| cluster_name | ECS cluster name | `string` | n/a | yes |
| service_name | ECS service name | `string` | n/a | yes |
| container_image | Docker image URL | `string` | n/a | yes |
| container_port | Container port | `number` | `80` | no |
| cpu | CPU units (256, 512, 1024, 2048, 4096) | `number` | `512` | no |
| memory | Memory in MB | `number` | `1024` | no |
| desired_count | Desired number of tasks | `number` | `2` | no |
| vpc_id | VPC ID | `string` | n/a | yes |
| private_subnet_ids | Private subnet IDs | `list(string)` | n/a | yes |
| enable_fargate_spot | Enable Fargate Spot | `bool` | `false` | no |
| fargate_spot_percentage | Percentage of tasks on Spot | `number` | `50` | no |
| enable_autoscaling | Enable auto-scaling | `bool` | `true` | no |
| min_capacity | Minimum tasks | `number` | `2` | no |
| max_capacity | Maximum tasks | `number` | `10` | no |
| environment_variables | Environment variables | `map(string)` | `{}` | no |
| secrets | Secrets from Secrets Manager/SSM | `list(object)` | `[]` | no |
| enable_execute_command | Enable ECS Exec | `bool` | `false` | no |

See [variables.tf](variables.tf) for complete list.

---

## 📤 Outputs

| Name | Description |
|------|-------------|
| service_arn | ARN of the ECS service |
| service_name | Name of the ECS service |
| cluster_arn | ARN of the ECS cluster |
| task_definition_arn | ARN of the task definition |
| security_group_id | Security group ID for ECS tasks |
| log_group_name | CloudWatch Log Group name |
| task_role_arn | IAM role ARN for tasks |

---

## 💰 Cost Estimation

### Monthly Costs (us-east-1)

**Fargate Standard:**
- 0.5 vCPU, 1 GB RAM: **~$14.50/task/month**
- 1 vCPU, 2 GB RAM: **~$29/task/month**
- 2 vCPU, 4 GB RAM: **~$58/task/month**

**Fargate Spot (70% savings):**
- 0.5 vCPU, 1 GB RAM: **~$4.35/task/month**
- 1 vCPU, 2 GB RAM: **~$8.70/task/month**
- 2 vCPU, 4 GB RAM: **~$17.40/task/month**

### Example: API Service (3 tasks, 0.5 vCPU, 1 GB)
- **Fargate Standard**: 3 × $14.50 = **~$44/month**
- **Fargate Spot (70%)**: 3 × $4.35 = **~$13/month**
- **Savings**: **~$31/month** (71% reduction)

### Additional Costs
- CloudWatch Logs: ~$0.50/GB ingested + $0.03/GB stored
- Load Balancer: ~$22/month + data processing
- NAT Gateway: ~$32/month/AZ (if tasks need internet)

### Cost Optimization Tips

1. **Use Fargate Spot**: 50-70% savings for fault-tolerant workloads
2. **Right-Size Resources**: Start small (256 CPU, 512 MB) and scale up
3. **Log Retention**: Use 7-day retention for dev/staging
4. **Service Discovery**: Reduce NAT Gateway usage for inter-service communication
5. **VPC Endpoints**: Free S3/DynamoDB access without NAT Gateway

---

## 🔒 Security Best Practices

### Built-In Security Features

✅ **Private Subnets Only**: Tasks run in private subnets with no public IPs  
✅ **Least-Privilege IAM**: Separate task and execution roles  
✅ **Secrets Management**: Encrypted secrets from Secrets Manager/SSM  
✅ **Security Groups**: Restrictive ingress limited to ALB only  
✅ **CloudWatch Logs**: Encrypted log storage  
✅ **IMDSv2**: Fargate enforces IMDSv2 by default  

### Security Recommendations

```hcl
# 1. Store secrets in AWS Secrets Manager
resource "aws_secretsmanager_secret" "db_password" {
  name = "prod/database-password"
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = var.db_password
}

# 2. Grant task role access to specific secrets only
resource "aws_iam_policy" "task_secrets" {
  name = "${var.service_name}-secrets-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["secretsmanager:GetSecretValue"]
        Resource = [aws_secretsmanager_secret.db_password.arn]
      }
    ]
  })
}

# 3. Enable container image scanning in ECR
resource "aws_ecr_repository" "app" {
  name                 = "my-app"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
  }
}
```

### Compliance

- **SOC 2**: CloudWatch Logs provide audit trail
- **PCI-DSS**: Encrypted secrets and network isolation
- **HIPAA**: Encryption at rest and in transit
- **GDPR**: Data residency through regional deployment

---

## 📊 Monitoring & Troubleshooting

### CloudWatch Container Insights

Enable Container Insights for detailed metrics:

```hcl
module "ecs_service" {
  source = "your-org/ecs-fargate-service/aws"

  cluster_name              = "production-cluster"
  enable_container_insights = true
  # ... other configuration
}
```

### Key Metrics to Monitor

- **CPUUtilization**: Target <70% average
- **MemoryUtilization**: Target <80% average
- **RunningTaskCount**: Should match desired count
- **HealthyHostCount**: All targets should be healthy
- **TargetResponseTime**: Monitor for latency spikes

### Debugging with ECS Exec

```hcl
# Enable ECS Exec in module
enable_execute_command = true
```

```bash
# SSH into a running task
aws ecs execute-command \
  --cluster production-cluster \
  --task <task-id> \
  --container api \
  --interactive \
  --command "/bin/bash"
```

### Common Issues

**Issue**: Tasks fail health checks and restart continuously  
**Solutions**:
- Increase `health_check_grace_period_seconds` (default: 60s)
- Verify container health check endpoint returns 200
- Check CloudWatch Logs for application errors

**Issue**: Tasks can't pull container image  
**Solutions**:
- Verify execution role has ECR permissions
- Check ECR repository policy allows account access
- Ensure tasks are in subnets with NAT Gateway or VPC endpoint for ECR

**Issue**: High costs from Fargate  
**Solutions**:
- Enable Fargate Spot (50-70% savings)
- Right-size CPU and memory
- Implement auto-scaling to reduce idle capacity
- Use scheduled scaling for predictable traffic patterns

---

## 🎯 Pro Version Features

**Upgrade to Pro tier ($499/month) for enterprise-grade ECS features:**

### 🎨 CloudWatch Container Insights Dashboards
- **Real-Time Container Metrics**: CPU, memory, network per task
- **Service Map**: Visualize service dependencies
- **Performance Monitoring**: Task startup time, deployment tracking
- **Cost Attribution**: Per-service and per-task cost breakdown

### 🔐 Advanced Security Baseline
- **GuardDuty Runtime Monitoring**: Threat detection for containers
- **ECR Image Scanning**: Automated vulnerability scanning
- **AWS Config Rules**: Compliance checks for ECS services
- **Security Hub Integration**: Centralized security findings
- **Runtime Security**: Falco/Sysdig integration

### ⚡ Advanced Scaling
- **Predictive Auto-Scaling**: ML-based capacity planning
- **Custom CloudWatch Metrics**: Scale on custom application metrics
- **SQS Queue-Based Scaling**: Scale workers based on queue depth
- **Scheduled Scaling**: Pre-scale for known traffic patterns
- **Service Auto Discovery**: Automatic Envoy/App Mesh integration

### 💰 FinOps Automation
- **Cost Anomaly Detection**: Alert on unexpected ECS charges
- **Right-Sizing Recommendations**: ML-based CPU/memory optimization
- **Savings Plans**: Guidance on Compute Savings Plans
- **Spot Interruption Handling**: Graceful task migration on spot interruptions
- **Idle Resource Detection**: Alert on underutilized services

### 🚀 CI/CD Integration
- **Blue/Green Deployments**: CodeDeploy integration for zero-downtime
- **Canary Releases**: Gradual traffic shifting with automatic rollback
- **GitHub Actions**: Pre-built workflows for ECS deployment
- **CodePipeline Templates**: End-to-end CI/CD pipelines
- **Automated Rollback**: Automatic rollback on deployment failures

### 🔄 Advanced Features
- **Service Mesh**: AWS App Mesh integration for microservices
- **Distributed Tracing**: X-Ray integration for request tracing
- **Multi-Region Deployment**: Active-active across regions
- **Disaster Recovery**: Automated failover and backup strategies

### 📞 Enterprise Support
- **24/7 Incident Response**: 4-hour SLA for production issues
- **Container Architecture Reviews**: Optimization recommendations
- **Migration Assistance**: EC2 to Fargate migration support
- **Performance Tuning**: Custom optimization for high-scale workloads

---

## 📚 Examples

See [examples/](examples/) directory:
- **Basic Fargate Service**: Simple web application
- **Cost-Optimized with Spot**: Staging environment with Fargate Spot
- **Advanced with Secrets**: Production API with Secrets Manager
- **Worker Service**: Background job processor without load balancer

---

## 🔄 Remote State Setup

### Initialize Backend

```bash
# Create backend.hcl
cat > backend.hcl <<EOF
bucket         = "my-company-terraform-state"
key            = "production/ecs-fargate-service/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "terraform-state-locks"
encrypt        = true
EOF

# Initialize with backend configuration
terraform init -backend-config=backend.hcl
```

### Bootstrap State Resources

Use the bootstrap resources in [examples/example.tf](examples/example.tf) to create S3 bucket and DynamoDB table.

---

## 🔄 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-10 | Initial release with Fargate Spot support |
| 1.1.0 | TBD | Add Service Connect support |

---

## 📝 Requirements

- Terraform >= 1.5.0
- AWS Provider >= 5.0
- Container image in ECR or public registry
- VPC with private subnets

---

## 🤝 Contributing

See [CONTRIBUTING.md](../../CONTRIBUTING.md)

---

## 📄 License

MIT License - see [LICENSE](LICENSE)

---

## 💬 Support

- **Community**: [GitHub Discussions](https://github.com/yourusername/aws-startup-terraform-modules/discussions)
- **Bug Reports**: [GitHub Issues](https://github.com/yourusername/aws-startup-terraform-modules/issues)
- **Pro Support**: support@example.com

---

## 🌟 Related Modules

- [ec2-autoscaling-app](../ec2-autoscaling-app/): Traditional EC2-based applications
- [eks-kubernetes-cluster](../eks-kubernetes-cluster/): Managed Kubernetes
- [lambda-api-gateway](../lambda-api-gateway/): Serverless functions
- [alb-loadbalancer](../../networking/alb-loadbalancer/): Application Load Balancer
- [rds-postgres-database](../../storage-databases/rds-postgres-database/): Managed PostgreSQL

---

**Built with ❤️ for modern containerized applications**

