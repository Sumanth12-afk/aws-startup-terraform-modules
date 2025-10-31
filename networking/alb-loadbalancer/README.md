# Application Load Balancer Module

**Production-ready AWS Application Load Balancer with SSL/TLS, path-based routing, and health checks.**

This Terraform module creates a fully-configured Application Load Balancer (ALB) with support for HTTPS, multiple target groups, path-based routing, and comprehensive monitoring. Perfect for distributing traffic across containerized applications, EC2 instances, or Lambda functions.

---

## 📋 Features

✅ **HTTPS/TLS Termination**: SSL certificate integration with ACM  
✅ **Auto HTTP→HTTPS Redirect**: Automatic redirect for secure connections  
✅ **Multi-Target Groups**: Support multiple backend services  
✅ **Path-Based Routing**: Route requests based on URL paths or hostnames  
✅ **Health Checks**: Configurable health monitoring for targets  
✅ **Session Stickiness**: Cookie-based session affinity  
✅ **CloudWatch Alarms**: Automated monitoring for response time, errors, unhealthy hosts  
✅ **Access Logs**: Optional logging to S3 for compliance  
✅ **Security Hardened**: Drop invalid headers, modern TLS policies  
✅ **WAF Ready**: Compatible with AWS WAF integration  

---

## 🏗️ Architecture

```
Internet
   ↓
[Route53] → app.example.com
   ↓
┌─────────────────────────────────────────┐
│   Application Load Balancer             │
│   - HTTPS:443 (SSL Termination)         │
│   - HTTP:80 (Redirect to HTTPS)         │
│                                         │
│   Listener Rules:                       │
│   /api/*     → API Target Group         │
│   /admin/*   → Admin Target Group       │
│   /*         → Web Target Group (default)│
└─────────────────────────────────────────┘
          ↓            ↓            ↓
   ┌──────────┐  ┌──────────┐  ┌──────────┐
   │ ECS Task │  │ ECS Task │  │ ECS Task │
   │ (API)    │  │ (Admin)  │  │ (Web)    │
   │ :8080    │  │ :9000    │  │ :3000    │
   └──────────┘  └──────────┘  └──────────┘
```

---

## 🚀 Usage

### Basic Example with HTTPS

```hcl
module "alb" {
  source = "your-org/alb-loadbalancer/aws"
  version = "~> 1.0"

  name       = "my-app-alb"
  vpc_id     = "vpc-12345678"
  subnet_ids = ["subnet-abc123", "subnet-def456"]

  # HTTPS Configuration
  enable_https            = true
  enable_http             = true
  http_redirect_to_https  = true
  certificate_arn         = "arn:aws:acm:us-east-1:123456789012:certificate/xxx"

  tags = {
    Project = "my-startup"
    Team    = "platform"
  }
}
```

### Microservices with Path-Based Routing

```hcl
module "alb" {
  source = "your-org/alb-loadbalancer/aws"
  version = "~> 1.0"

  name       = "microservices-alb"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids

  environment = "production"

  enable_https            = true
  certificate_arn         = var.certificate_arn
  http_redirect_to_https  = true

  # Define multiple target groups
  target_groups = {
    api = {
      port                 = 8080
      protocol             = "HTTP"
      target_type          = "ip"
      deregistration_delay = 30
      health_check = {
        enabled             = true
        healthy_threshold   = 2
        unhealthy_threshold = 3
        timeout             = 5
        interval            = 30
        path                = "/api/health"
        port                = "traffic-port"
        protocol            = "HTTP"
        matcher             = "200"
      }
      stickiness_enabled  = true
      stickiness_duration = 3600
    }

    web = {
      port                 = 3000
      protocol             = "HTTP"
      target_type          = "ip"
      deregistration_delay = 30
      health_check = {
        enabled             = true
        healthy_threshold   = 2
        unhealthy_threshold = 3
        timeout             = 5
        interval            = 30
        path                = "/health"
        port                = "traffic-port"
        protocol            = "HTTP"
        matcher             = "200-299"
      }
      stickiness_enabled  = false
      stickiness_duration = 86400
    }
  }

  default_target_group = "web"

  # Path-based routing
  listener_rules = {
    api_route = {
      priority      = 100
      target_group  = "api"
      path_patterns = ["/api/*", "/v1/*"]
      host_headers  = null
    }
  }

  # Monitoring
  enable_cloudwatch_alarms       = true
  alarm_actions                  = [aws_sns_topic.alerts.arn]
  target_response_time_threshold = 2.0

  tags = {
    Project = "my-startup"
  }
}
```

---

## 📥 Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the ALB | `string` | n/a | yes |
| vpc_id | VPC ID where ALB will be deployed | `string` | n/a | yes |
| subnet_ids | List of subnet IDs (min 2 in different AZs) | `list(string)` | n/a | yes |
| environment | Environment name | `string` | `"production"` | no |
| internal | Whether ALB is internal or internet-facing | `bool` | `false` | no |
| enable_https | Enable HTTPS listener (port 443) | `bool` | `true` | no |
| enable_http | Enable HTTP listener (port 80) | `bool` | `true` | no |
| http_redirect_to_https | Redirect HTTP to HTTPS | `bool` | `true` | no |
| certificate_arn | ARN of SSL certificate (required if HTTPS enabled) | `string` | `""` | no |
| ssl_policy | SSL policy for HTTPS listener | `string` | `"ELBSecurityPolicy-TLS13-1-2-2021-06"` | no |
| target_groups | Map of target group configurations | `map(object)` | See below | no |
| default_target_group | Name of the default target group | `string` | `"default"` | no |
| listener_rules | Map of listener rule configurations | `map(object)` | `{}` | no |
| enable_cloudwatch_alarms | Enable CloudWatch alarms | `bool` | `false` | no |
| enable_access_logs | Enable access logs to S3 | `bool` | `false` | no |
| idle_timeout | Connection idle timeout (seconds) | `number` | `60` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

---

## 📤 Outputs

| Name | Description |
|------|-------------|
| alb_dns_name | DNS name of the ALB (use for Route53 ALIAS) |
| alb_zone_id | Hosted zone ID of the ALB |
| alb_arn | ARN of the ALB |
| security_group_id | Security group ID attached to ALB |
| target_group_arns | Map of target group names to ARNs |
| https_listener_arn | ARN of HTTPS listener |

---

## 💰 Cost Estimation

### Monthly Costs (us-east-1)

**Basic ALB:**
- ALB Instance: **$22.27/month** (~$0.0225/hour × 730 hours)
- LCU Usage: **Variable** ($0.008 per LCU-hour)
  - 1 LCU = 25 new connections/sec, 3000 active connections, 1 GB/hour traffic, or 1000 rule evaluations/sec
- **Estimated Total: $30-100/month** (depending on traffic)

**With Access Logs:**
- S3 Storage: ~$5-20/month (depending on request volume)
- Data Transfer: Included in LCU pricing

### Cost Optimization Tips

1. **Use Single ALB**: Share ALB across multiple services with path-based routing
2. **Disable Access Logs**: For non-production environments
3. **Optimize Health Checks**: Reduce frequency in dev/staging
4. **CloudFront CDN**: Offload static content to reduce ALB traffic

---

## 🔒 Security Best Practices

### SSL/TLS Configuration

**Recommended SSL Policies:**
- **Production**: `ELBSecurityPolicy-TLS13-1-2-2021-06` (TLS 1.3 + 1.2)
- **Legacy Support**: `ELBSecurityPolicy-TLS-1-2-2017-01` (TLS 1.2 only)
- **Modern Only**: `ELBSecurityPolicy-TLS13-1-3-2021-06` (TLS 1.3 only)

### Security Group Best Practices

```hcl
# Restrict ALB to CloudFlare IPs (if using CF)
module "alb" {
  source = "your-org/alb-loadbalancer/aws"

  name       = "app-alb"
  vpc_id     = var.vpc_id
  subnet_ids = var.public_subnet_ids

  # Only allow CloudFlare IPs
  allowed_cidr_blocks = [
    "173.245.48.0/20",
    "103.21.244.0/22",
    # ... other CloudFlare IPs
  ]

  # Additional security
  drop_invalid_header_fields = true

  tags = {
    Project = "my-app"
  }
}
```

### WAF Integration (Pro Version)

```hcl
# AWS WAF Web ACL
resource "aws_wafv2_web_acl" "main" {
  name  = "app-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "RateLimitRule"
    priority = 1

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }

    action {
      block {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitRule"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "AppWAF"
    sampled_requests_enabled   = true
  }
}

# Associate WAF with ALB
resource "aws_wafv2_web_acl_association" "main" {
  resource_arn = module.alb.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}
```

---

## 📊 Monitoring & Troubleshooting

### CloudWatch Metrics

Key metrics to monitor:
- **TargetResponseTime**: Target response time in seconds
- **HTTPCode_Target_5XX_Count**: 5XX errors from targets
- **HTTPCode_ELB_5XX_Count**: 5XX errors from ALB itself
- **UnHealthyHostCount**: Number of unhealthy targets
- **ActiveConnectionCount**: Current connections
- **RequestCount**: Total requests

### Common Issues

**Issue**: 502 Bad Gateway  
**Causes**:
- Target health check failing
- Target not responding within timeout
- Security group blocking ALB → Target traffic

**Solution**:
```bash
# Check target health
aws elbv2 describe-target-health \
  --target-group-arn <target-group-arn>

# Verify security group allows traffic from ALB
# Target security group must allow ingress from ALB security group
```

**Issue**: High response times  
**Solutions**:
- Enable connection draining
- Increase target count
- Add caching layer (CloudFront, ElastiCache)
- Optimize application code

---

## 🎯 Pro Version Features

**Upgrade to Pro tier ($499/month) for advanced load balancing:**

### 🎨 Enhanced CloudWatch Dashboards
- **Real-Time Traffic Visualization**: Request rates, error rates, response times
- **Target Health Monitoring**: Per-target health status and metrics
- **Geographic Traffic Analysis**: Request origin mapping
- **Cost Attribution**: Per-service cost breakdown for shared ALBs

### 🔐 Advanced Security (WAF Integration)
- **Pre-Configured WAF Rules**: SQL injection, XSS, known bad IPs
- **Rate Limiting**: Per-IP and per-path rate limits
- **Geo-Blocking**: Block traffic from specific countries
- **Bot Protection**: Automated bot detection and mitigation
- **DDoS Protection**: Integration with AWS Shield Advanced

### ⚡ Performance Optimization
- **Connection Draining**: Graceful target deregistration
- **Lambda@Edge Integration**: Request/response transformation
- **Advanced Health Checks**: Custom health check endpoints per service
- **Weighted Target Groups**: Blue/green and canary deployments

### 💰 FinOps Automation
- **LCU Cost Analysis**: Detailed breakdown of LCU charges
- **Traffic Pattern Analysis**: Identify cost optimization opportunities
- **Unused ALB Detection**: Alert on underutilized load balancers
- **Savings Recommendations**: Right-sizing and consolidation guidance

### 🚀 CI/CD Integration
- **Blue/Green Deployments**: Automated traffic shifting between target groups
- **Canary Releases**: Gradual traffic migration with automated rollback
- **Terraform Workspaces**: Multi-environment management
- **Automated Testing**: Health check validation in CI pipelines

### 📞 Enterprise Support
- **24/7 Incident Response**: 4-hour SLA for production issues
- **Architecture Reviews**: ALB design optimization assessments
- **Performance Tuning**: Custom optimization for high-traffic applications

---

## 📚 Examples

See [examples/](examples/) directory:
- **Basic HTTPS ALB**: Simple setup with SSL termination
- **Microservices Routing**: Path-based routing for multiple services
- **Internal ALB**: Private load balancer for backend services
- **Multi-Domain**: SNI support for multiple SSL certificates

---

## 🔄 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-10 | Initial release |
| 1.1.0 | TBD | Add NLB support |

---

## 📝 Requirements

- Terraform >= 1.5.0
- AWS Provider >= 5.0
- ACM certificate (if using HTTPS)

---

## 🤝 Contributing

See [CONTRIBUTING.md](../../CONTRIBUTING.md)

---

## 📄 License

MIT License - see [LICENSE](LICENSE)

---

## 💬 Support

- **Community**: [GitHub Discussions](https://github.com/yourusername/aws-startup-terraform-modules/discussions)
- **Pro Support**: support@example.com

---

**Built with ❤️ for modern cloud applications**

