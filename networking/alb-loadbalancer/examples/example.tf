# Example: Application Load Balancer Module Usage

# Prerequisite: VPC module (or existing VPC)
module "vpc" {
  source = "../../vpc-networking"

  environment        = "production"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

  tags = {
    Project = "my-startup"
  }
}

# Example 1: Basic ALB with HTTPS and HTTP-to-HTTPS redirect
module "alb_basic" {
  source = "../"

  name       = "my-app-alb"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids

  environment = "production"

  # HTTPS Configuration
  enable_https            = true
  enable_http             = true
  http_redirect_to_https  = true
  certificate_arn         = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"

  # Security
  allowed_cidr_blocks = ["0.0.0.0/0"]

  tags = {
    Project = "my-startup"
    Team    = "platform"
  }
}

# Example 2: Advanced ALB with Multiple Target Groups and Path-Based Routing
module "alb_microservices" {
  source = "../"

  name       = "microservices-alb"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids

  environment = "production"

  # HTTPS Configuration
  enable_https            = true
  enable_http             = true
  http_redirect_to_https  = true
  certificate_arn         = "arn:aws:acm:us-east-1:123456789012:certificate/your-cert-id"
  ssl_policy              = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  # Multiple Target Groups for Microservices
  target_groups = {
    api = {
      port                 = 8080
      protocol             = "HTTP"
      target_type          = "instance"
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
      target_type          = "instance"
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

    admin = {
      port                 = 9000
      protocol             = "HTTP"
      target_type          = "ip"
      deregistration_delay = 60
      health_check = {
        enabled             = true
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 5
        interval            = 30
        path                = "/admin/status"
        port                = "traffic-port"
        protocol            = "HTTP"
        matcher             = "200"
      }
      stickiness_enabled  = true
      stickiness_duration = 7200
    }
  }

  default_target_group = "web"

  # Path-Based Routing Rules
  listener_rules = {
    api_route = {
      priority      = 100
      target_group  = "api"
      path_patterns = ["/api/*", "/v1/*", "/v2/*"]
      host_headers  = null
    }

    admin_route = {
      priority      = 200
      target_group  = "admin"
      path_patterns = ["/admin/*"]
      host_headers  = null
    }

    domain_based = {
      priority      = 300
      target_group  = "web"
      path_patterns = null
      host_headers  = ["www.example.com", "example.com"]
    }
  }

  # Access Logs
  enable_access_logs  = true
  access_logs_bucket  = "my-alb-logs-bucket"
  access_logs_prefix  = "production-alb"

  # CloudWatch Alarms
  enable_cloudwatch_alarms         = true
  alarm_actions                    = ["arn:aws:sns:us-east-1:123456789012:alerts"]
  target_response_time_threshold   = 2.0
  unhealthy_host_threshold         = 2
  elb_5xx_threshold                = 50

  # Advanced Configuration
  enable_deletion_protection       = true
  enable_cross_zone_load_balancing = true
  enable_http2                     = true
  drop_invalid_header_fields       = true
  idle_timeout                     = 120

  tags = {
    Project     = "my-startup"
    Team        = "platform"
    Environment = "production"
  }
}

# Example 3: Internal ALB for Private Services
module "alb_internal" {
  source = "../"

  name       = "internal-services-alb"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  environment = "production"
  internal    = true  # Internal ALB

  # HTTP Only (internal services don't need HTTPS)
  enable_https           = false
  enable_http            = true
  http_redirect_to_https = false

  # Restrict to VPC CIDR
  allowed_cidr_blocks = [module.vpc.vpc_cidr]

  target_groups = {
    backend = {
      port                 = 8080
      protocol             = "HTTP"
      target_type          = "ip"  # For ECS Fargate
      deregistration_delay = 30
      health_check = {
        enabled             = true
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 5
        interval            = 10
        path                = "/health"
        port                = "traffic-port"
        protocol            = "HTTP"
        matcher             = "200"
      }
      stickiness_enabled  = false
      stickiness_duration = 86400
    }
  }

  default_target_group = "backend"

  enable_deletion_protection = false  # Allow easier cleanup for dev

  tags = {
    Project     = "my-startup"
    Team        = "platform"
    Environment = "production"
    Type        = "internal"
  }
}

# Example 4: Development ALB (Cost-Optimized)
module "alb_dev" {
  source = "../"

  name       = "dev-alb"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids

  environment = "dev"

  # Basic HTTP only for dev
  enable_https           = false
  enable_http            = true
  http_redirect_to_https = false

  # Disable expensive features
  enable_deletion_protection = false
  enable_access_logs         = false
  enable_cloudwatch_alarms   = false

  tags = {
    Project     = "my-startup"
    Team        = "platform"
    Environment = "dev"
  }
}

# Outputs
output "alb_dns_name" {
  description = "ALB DNS name for CNAME/ALIAS records"
  value       = module.alb_basic.alb_dns_name
}

output "alb_zone_id" {
  description = "ALB hosted zone ID for Route53"
  value       = module.alb_basic.alb_zone_id
}

output "target_group_arns" {
  description = "Target group ARNs for microservices"
  value       = module.alb_microservices.target_group_arns
}

output "security_group_id" {
  description = "ALB security group ID"
  value       = module.alb_basic.security_group_id
}

# Example Route53 Record (if using custom domain)
# resource "aws_route53_record" "app" {
#   zone_id = "Z1234567890ABC"
#   name    = "app.example.com"
#   type    = "A"
#
#   alias {
#     name                   = module.alb_basic.alb_dns_name
#     zone_id                = module.alb_basic.alb_zone_id
#     evaluate_target_health = true
#   }
# }

