# Networking Modules

**Foundation for secure, scalable AWS network infrastructure.**

This category provides the essential building blocks for AWS networking architecture. These modules establish VPC infrastructure, connectivity, and load balancing capabilities that serve as the foundation for all other AWS services.

---

## 🏗️ Modules in This Category

| Module | Purpose | Key Features |
|--------|---------|--------------|
| **vpc-networking** | Multi-AZ VPC with public/private subnets | IPv4/IPv6, Flow Logs, DHCP options |
| **internet-gateway-nat** | Internet connectivity for public/private subnets | NAT Gateways, Elastic IPs, route tables |
| **alb-loadbalancer** | Application Load Balancer with SSL/TLS | HTTPS, health checks, target groups |

---

## 🎯 Purpose

These networking modules enable startups to:

- **Establish Secure Foundations**: Multi-AZ VPCs with proper subnet segmentation
- **Control Internet Access**: Managed NAT Gateways for private subnet egress
- **Distribute Traffic**: Application Load Balancers with SSL termination and health checks
- **Scale Automatically**: Infrastructure that grows with your application demands
- **Follow Best Practices**: Security groups, NACLs, and flow logs built-in

---

## 🏛️ Architecture Flow

A typical startup networking architecture combines these modules:

```
┌─────────────────────────────────────────────────────────────────┐
│                         AWS Region                              │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    VPC (10.0.0.0/16)                     │  │
│  │                                                          │  │
│  │  ┌──────────────────────┐  ┌──────────────────────┐    │  │
│  │  │  AZ-1 (us-east-1a)   │  │  AZ-2 (us-east-1b)   │    │  │
│  │  │                      │  │                      │    │  │
│  │  │ ┌─────────────────┐  │  │ ┌─────────────────┐  │    │  │
│  │  │ │ Public Subnet   │  │  │ │ Public Subnet   │  │    │  │
│  │  │ │ 10.0.1.0/24     │  │  │ │ 10.0.2.0/24     │  │    │  │
│  │  │ │                 │  │  │ │                 │  │    │  │
│  │  │ │  [NAT Gateway]  │  │  │ │  [NAT Gateway]  │  │    │  │
│  │  │ │       ↑         │  │  │ │       ↑         │  │    │  │
│  │  │ └───────┼─────────┘  │  │ └───────┼─────────┘  │    │  │
│  │  │         │            │  │         │            │    │  │
│  │  │    [Internet GW]────┼──┼─────────┘            │    │  │
│  │  │         │            │  │                      │    │  │
│  │  │         ↓            │  │         ↓            │    │  │
│  │  │ ┌─────────────────┐  │  │ ┌─────────────────┐  │    │  │
│  │  │ │      ALB        │  │  │ │    ALB (HA)     │  │    │  │
│  │  │ │  (Listener:443) │  │  │ │                 │  │    │  │
│  │  │ └─────────────────┘  │  │ └─────────────────┘  │    │  │
│  │  │         │            │  │         │            │    │  │
│  │  │         ↓            │  │         ↓            │    │  │
│  │  │ ┌─────────────────┐  │  │ ┌─────────────────┐  │    │  │
│  │  │ │ Private Subnet  │  │  │ │ Private Subnet  │  │    │  │
│  │  │ │ 10.0.11.0/24    │  │  │ │ 10.0.12.0/24    │  │    │  │
│  │  │ │                 │  │  │ │                 │  │    │  │
│  │  │ │  [ECS Tasks]    │  │  │ │  [ECS Tasks]    │  │    │  │
│  │  │ │  [RDS Primary]  │  │  │ │  [RDS Replica]  │  │    │  │
│  │  │ └─────────────────┘  │  │ └─────────────────┘  │    │  │
│  │  └──────────────────────┘  └──────────────────────┘    │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### Traffic Flow

1. **External Traffic**: Internet → Internet Gateway → ALB (Public Subnets) → Target Group (Private Subnets)
2. **Outbound from Private**: Private Subnet → NAT Gateway (Public Subnet) → Internet Gateway → Internet
3. **Database Access**: Application (Private Subnet) → RDS (Private Subnet) - No internet access

---

## 🚀 Quick Start Example

Deploy a complete networking stack:

```hcl
# 1. Create VPC with subnets
module "vpc" {
  source = "./vpc-networking"

  environment        = "production"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  
  enable_flow_logs   = true
  enable_nat_gateway = true

  tags = {
    Project = "my-startup"
    Team    = "platform"
  }
}

# 2. Setup Internet Gateway and NAT
module "nat_gateway" {
  source = "./internet-gateway-nat"

  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  availability_zones = module.vpc.availability_zones

  tags = {
    Project = "my-startup"
    Team    = "platform"
  }
}

# 3. Deploy Application Load Balancer
module "alb" {
  source = "./alb-loadbalancer"

  name               = "my-app-alb"
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  
  certificate_arn    = "arn:aws:acm:us-east-1:123456789012:certificate/xxx"
  enable_https       = true

  tags = {
    Project = "my-startup"
    Team    = "platform"
  }
}
```

---

## 💡 Common Use Cases

### Scenario 1: Basic Web Application
- **Modules**: vpc-networking + internet-gateway-nat + alb-loadbalancer
- **Architecture**: Public ALB → Private ECS/EC2 instances → Private RDS
- **Cost**: ~$150-250/month (depends on traffic and NAT Gateway usage)

### Scenario 2: Microservices Platform
- **Modules**: vpc-networking + internet-gateway-nat + alb-loadbalancer (with path-based routing)
- **Architecture**: Multiple target groups behind single ALB for different services
- **Cost**: ~$200-400/month

### Scenario 3: Multi-Environment Setup
- **Modules**: Separate VPC per environment (dev, staging, prod)
- **Architecture**: VPC peering or Transit Gateway for inter-environment communication
- **Cost**: ~$300-600/month

---

## 🔒 Security Best Practices

✅ **Network Segmentation**: Public subnets for load balancers, private subnets for applications/databases  
✅ **Least Privilege**: Security groups allow only necessary traffic  
✅ **Encryption in Transit**: ALB supports TLS 1.2+, HTTP to HTTPS redirect  
✅ **Flow Logs**: VPC Flow Logs capture all network traffic for audit/analysis  
✅ **NAT Gateway**: Prevents direct internet access to private resources  
✅ **Multi-AZ**: High availability across multiple availability zones  

---

## 💰 Cost Optimization Tips

- **NAT Gateways**: Biggest cost factor (~$32/month per AZ). Consider single NAT for dev/staging
- **ALB**: ~$22/month + data processing costs. Use target groups efficiently
- **VPC Flow Logs**: Store in S3 with lifecycle policies, not CloudWatch Logs
- **Elastic IPs**: Free when attached, $3.60/month when idle
- **Data Transfer**: Use VPC endpoints to avoid NAT Gateway charges for AWS services

### Monthly Cost Estimate (us-east-1)

| Component | Configuration | Monthly Cost |
|-----------|--------------|--------------|
| VPC | Free tier | $0 |
| Internet Gateway | Free tier | $0 |
| NAT Gateway | 3 AZs | ~$96 |
| Elastic IPs | 3 (for NAT) | $0 |
| ALB | 1 instance | ~$22 |
| VPC Flow Logs | S3 storage | ~$5-15 |
| **Total** | | **~$123-133/month** |

*Add data transfer costs based on traffic volume*

---

## 📈 Pro Version Features

**Upgrade to Pro tier for advanced networking capabilities:**

### 🎯 Enhanced Monitoring
- **CloudWatch Dashboards**: Real-time network metrics (bandwidth, packet loss, connection counts)
- **Custom Alarms**: Alert on abnormal traffic patterns, NAT Gateway throttling, ALB error rates
- **Traffic Analytics**: Flow log analysis with automated anomaly detection

### 🔐 Advanced Security
- **AWS WAF Integration**: Pre-configured rule sets for common attacks (SQL injection, XSS, DDoS)
- **GuardDuty VPC Integration**: Automatic threat detection and response
- **Network Firewall**: Stateful firewall rules for granular traffic control
- **VPC Endpoints**: Secure access to S3, DynamoDB, and other AWS services without internet egress

### ⚡ Performance & HA
- **Auto-Scaling ALB**: Dynamic capacity based on traffic patterns
- **Connection Draining**: Graceful instance deregistration during deployments
- **Cross-Zone Load Balancing**: Optimal traffic distribution
- **IPv6 Support**: Dual-stack networking

### 💰 FinOps Automation
- **Cost Anomaly Detection**: Alert on unexpected NAT Gateway or ALB charges
- **Right-Sizing Recommendations**: Optimize NAT Gateway and ALB sizing
- **Reserved Capacity**: Guidance on Savings Plans for consistent workloads

### 🚀 CI/CD Integration
- **Terraform Cloud Workspaces**: Automated deployments with policy-as-code
- **Network Testing**: Automated connectivity and latency tests
- **Blue/Green Deployments**: ALB-based deployment strategies

---

## 📚 Additional Resources

- [AWS VPC Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-best-practices.html)
- [ALB vs NLB vs CLB Comparison](docs/load-balancer-comparison.md)
- [Multi-Region Networking](docs/multi-region-setup.md)
- [VPC Peering vs Transit Gateway](docs/vpc-connectivity.md)

---

## 🤝 Support

- **Community**: [GitHub Discussions](https://github.com/yourusername/aws-startup-terraform-modules/discussions)
- **Pro/Enterprise**: priority-support@example.com

---

**Next Steps**: Explore [Compute Modules](../compute/) to deploy applications in your new VPC infrastructure.

