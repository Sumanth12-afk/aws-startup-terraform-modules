# Compute Modules

**Production-ready compute resources for containerized, serverless, and scalable application deployments.**

This category provides compute infrastructure modules that enable startups to deploy applications across various AWS compute platforms - from traditional EC2 instances to modern serverless architectures.

---

## 🏗️ Modules in This Category

| Module | Purpose | Key Features |
|--------|---------|--------------|
| **ec2-autoscaling-app** | Auto-scaling EC2 instances with ALB | Launch templates, ASG, health checks, spot instances |
| **eks-kubernetes-cluster** | Managed Kubernetes cluster | EKS control plane, managed node groups, IRSA, CNI |
| **ecs-fargate-service** | Serverless container deployment | ECS cluster, Fargate tasks, service discovery |
| **lambda-api-gateway** | Serverless API with Lambda | API Gateway, Lambda functions, authorizers |

---

## 🎯 Purpose

These compute modules enable startups to:

- **Deploy Applications Fast**: Pre-configured compute infrastructure ready in minutes
- **Scale Automatically**: Built-in auto-scaling based on metrics
- **Optimize Costs**: Support for spot instances, Fargate Spot, and Lambda cost optimization
- **Container-Ready**: Native support for Docker, Kubernetes, and ECS
- **Serverless Options**: Lambda-based APIs for event-driven architectures

---

## 🏛️ Architecture Patterns

### Pattern 1: Traditional Web Application (EC2)
```
ALB → EC2 Auto Scaling Group → RDS Database
- Best for: Legacy apps, steady workloads
- Cost: Predictable with Reserved Instances
```

### Pattern 2: Containerized Microservices (ECS Fargate)
```
ALB → ECS Fargate Services → DynamoDB/RDS
- Best for: Microservices, Docker-based apps
- Cost: Pay-per-use, no instance management
```

### Pattern 3: Kubernetes Platform (EKS)
```
ALB/NLB → EKS Cluster (Node Groups) → Storage
- Best for: Complex orchestration, multi-tenant apps
- Cost: Higher but feature-rich
```

### Pattern 4: Serverless API (Lambda + API Gateway)
```
API Gateway → Lambda Functions → DynamoDB
- Best for: APIs, event processing, low traffic
- Cost: Very low for intermittent traffic
```

---

## 🚀 Quick Start

### Deploy ECS Fargate Application

```hcl
module "vpc" {
  source = "../networking/vpc-networking"
  environment = "production"
  vpc_cidr = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]
}

module "alb" {
  source = "../networking/alb-loadbalancer"
  name = "app-alb"
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids
}

module "ecs_service" {
  source = "./ecs-fargate-service"
  
  cluster_name = "production-cluster"
  service_name = "api-service"
  
  container_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/api:latest"
  container_port = 8080
  
  vpc_id = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  target_group_arn = module.alb.default_target_group_arn
  
  desired_count = 3
  cpu = 512
  memory = 1024
  
  environment = "production"
}
```

---

## 💰 Cost Comparison

| Compute Option | Small App | Medium App | Large App | Best For |
|----------------|-----------|------------|-----------|----------|
| **EC2 (t3.medium)** | ~$30/mo | ~$120/mo | ~$500/mo | Steady workloads |
| **ECS Fargate** | ~$40/mo | ~$200/mo | ~$800/mo | Containerized apps |
| **EKS** | ~$73/mo* | ~$300/mo | ~$1000/mo | Kubernetes needs |
| **Lambda** | ~$5/mo | ~$50/mo | ~$500/mo | Event-driven, APIs |

*EKS includes $73/month control plane cost

---

## 🔒 Security Best Practices

✅ **IMDSv2 Enforced**: Require IMDSv2 for EC2 instances  
✅ **Private Subnets**: Compute resources in private subnets only  
✅ **IAM Roles**: Instance profiles and task roles with least privilege  
✅ **Secrets Management**: Integration with Secrets Manager/SSM  
✅ **Encryption**: EBS volumes and container storage encrypted  
✅ **Security Groups**: Restrictive ingress/egress rules  

---

## 📈 Pro Version Features

**Upgrade to Pro tier for advanced compute capabilities:**

### 🎯 Enhanced Monitoring
- **CloudWatch Container Insights**: Real-time container metrics
- **EKS Metrics**: Pod-level monitoring and cluster observability
- **Custom Dashboards**: Pre-built for EC2, ECS, EKS, Lambda
- **Distributed Tracing**: X-Ray integration for serverless

### 🔐 Advanced Security
- **GuardDuty Runtime Monitoring**: Threat detection for containers
- **AWS Config Rules**: Compliance checks for compute resources
- **Security Hub Integration**: Centralized security findings
- **Vulnerability Scanning**: ECR image scanning automation

### ⚡ Auto-Scaling & Performance
- **Predictive Scaling**: ML-based capacity planning
- **Karpenter for EKS**: Just-in-time node provisioning
- **Lambda Provisioned Concurrency**: Reduced cold starts
- **Spot Instance Orchestration**: Automated spot/on-demand mix

### 💰 FinOps Automation
- **Cost Allocation Tags**: Per-service cost breakdown
- **Right-Sizing Recommendations**: Automated instance optimization
- **Savings Plans**: Guidance on compute commitments
- **Spot Advisor**: Real-time spot pricing and interruption tracking

### 🚀 CI/CD Integration
- **Blue/Green Deployments**: Automated ECS/EKS deployments
- **Canary Releases**: Gradual traffic shifting with rollback
- **GitOps**: Flux/ArgoCD setup for EKS
- **Pipeline Templates**: CodePipeline and GitHub Actions

---

## 📚 Additional Resources

- [EC2 vs ECS vs EKS vs Lambda Guide](docs/compute-comparison.md)
- [Container Image Best Practices](docs/container-security.md)
- [Spot Instance Strategies](docs/spot-instances.md)
- [Lambda Performance Optimization](docs/lambda-optimization.md)

---

## 🤝 Support

- **Community**: [GitHub Discussions](https://github.com/yourusername/aws-startup-terraform-modules/discussions)
- **Pro/Enterprise**: support@example.com

---

**Next Steps**: Combine with [Storage & Databases](../storage-databases/) for a complete application stack.

