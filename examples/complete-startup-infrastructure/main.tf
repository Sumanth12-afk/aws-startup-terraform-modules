# Complete Startup Infrastructure Example
# This example demonstrates how to deploy a full production environment
# using multiple modules from the aws-startup-terraform-modules library

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "my-company-terraform-state"
    key            = "production/complete-infrastructure/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Repository  = "aws-startup-terraform-modules"
    }
  }
}

# =========================================
# 1. NETWORKING LAYER
# =========================================

module "vpc" {
  source = "../../networking/vpc-networking"

  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  project_name       = var.project_name

  enable_nat_gateway         = true
  single_nat_gateway         = var.environment != "production"
  enable_database_subnets    = true
  enable_flow_logs           = true
  flow_logs_destination_type = "s3"

  tags = {
    Layer = "networking"
  }
}

module "alb" {
  source = "../../networking/alb-loadbalancer"

  name         = "${var.project_name}-alb"
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.public_subnet_ids
  environment  = var.environment
  project_name = var.project_name

  enable_https           = true
  enable_http            = true
  http_redirect_to_https = true
  certificate_arn        = var.certificate_arn

  # Multiple target groups for different services
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
        path                = "/health"
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
        path                = "/"
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

  enable_cloudwatch_alarms = true
  alarm_actions            = [aws_sns_topic.alerts.arn]

  tags = {
    Layer = "networking"
  }
}

# =========================================
# 2. COMPUTE LAYER
# =========================================

# Backend API Service (ECS Fargate)
module "backend_api" {
  source = "../../compute/ecs-fargate-service"

  aws_region   = var.aws_region
  environment  = var.environment
  project_name = var.project_name

  cluster_name              = "${var.project_name}-cluster"
  create_cluster            = true
  enable_container_insights = true

  service_name    = "backend-api"
  desired_count   = var.environment == "production" ? 3 : 2
  container_image = var.backend_image
  container_port  = 8080

  cpu    = 1024
  memory = 2048

  # Cost optimization with Fargate Spot
  enable_fargate_spot     = var.enable_fargate_spot
  fargate_spot_percentage = 70

  # Environment variables
  environment_variables = {
    NODE_ENV      = var.environment
    LOG_LEVEL     = "info"
    PORT          = "8080"
    DATABASE_HOST = module.rds.endpoint
    REDIS_HOST    = "redis.internal.example.com" # Would come from ElastiCache
  }

  # Secrets from AWS Secrets Manager
  secrets = [
    {
      name      = "DATABASE_PASSWORD"
      valueFrom = aws_secretsmanager_secret.db_password.arn
    },
    {
      name      = "JWT_SECRET"
      valueFrom = aws_secretsmanager_secret.jwt_secret.arn
    }
  ]

  # Networking
  vpc_id                     = module.vpc.vpc_id
  private_subnet_ids         = module.vpc.private_subnet_ids
  allowed_security_group_ids = [module.alb.security_group_id]

  # Load balancer integration
  enable_load_balancer              = true
  target_group_arn                  = module.alb.target_group_arns["api"]
  health_check_grace_period_seconds = 60

  # Auto-scaling
  enable_autoscaling  = true
  min_capacity        = var.environment == "production" ? 2 : 1
  max_capacity        = var.environment == "production" ? 20 : 5
  cpu_target_value    = 70
  memory_target_value = 80

  # Monitoring
  enable_logging     = true
  log_retention_days = var.environment == "production" ? 90 : 30

  tags = {
    Layer   = "compute"
    Service = "backend-api"
  }
}

# Frontend Web Service (ECS Fargate)
module "frontend_web" {
  source = "../../compute/ecs-fargate-service"

  aws_region   = var.aws_region
  environment  = var.environment
  project_name = var.project_name

  cluster_name   = "${var.project_name}-cluster"
  create_cluster = false # Reuse cluster from backend

  service_name    = "frontend-web"
  desired_count   = var.environment == "production" ? 2 : 1
  container_image = var.frontend_image
  container_port  = 3000

  cpu    = 512
  memory = 1024

  enable_fargate_spot     = var.enable_fargate_spot
  fargate_spot_percentage = 50

  environment_variables = {
    NEXT_PUBLIC_API_URL = "https://${var.domain_name}/api"
    NODE_ENV            = var.environment
  }

  vpc_id                     = module.vpc.vpc_id
  private_subnet_ids         = module.vpc.private_subnet_ids
  allowed_security_group_ids = [module.alb.security_group_id]

  enable_load_balancer = true
  target_group_arn     = module.alb.target_group_arns["web"]

  enable_autoscaling = true
  min_capacity       = var.environment == "production" ? 2 : 1
  max_capacity       = 10

  tags = {
    Layer   = "compute"
    Service = "frontend-web"
  }
}

# Serverless Functions (Lambda)
module "lambda_functions" {
  source = "../../compute/lambda-api-gateway"

  aws_region   = var.aws_region
  environment  = var.environment
  project_name = var.project_name

  api_name   = "${var.project_name}-serverless-api"
  stage_name = var.environment

  lambda_functions = {
    image_processor = {
      handler          = "index.handler"
      runtime          = "nodejs20.x"
      filename         = "${path.module}/lambda/image-processor.zip"
      source_code_hash = filebase64sha256("${path.module}/lambda/image-processor.zip")
      memory_size      = 1024
      timeout          = 60
      environment_variables = {
        S3_BUCKET = "my-images-bucket"
      }
      http_method   = "POST"
      http_path     = "/process-image"
      authorization = "AWS_IAM"
    }
  }

  enable_cors        = true
  cors_allow_origins = ["https://${var.domain_name}"]
  enable_xray        = true

  tags = {
    Layer = "serverless"
  }
}

# =========================================
# 3. DATABASE LAYER
# =========================================

# RDS PostgreSQL Database (placeholder - to be implemented)
resource "aws_db_instance" "main" {
  identifier     = "${var.project_name}-db"
  engine         = "postgres"
  engine_version = "15.4"

  instance_class    = var.environment == "production" ? "db.t4g.medium" : "db.t4g.micro"
  allocated_storage = 20
  storage_encrypted = true

  db_name  = var.database_name
  username = var.database_username
  password = random_password.db_password.result

  multi_az               = var.environment == "production"
  db_subnet_group_name   = module.vpc.database_subnet_group_name
  vpc_security_group_ids = [aws_security_group.rds.id]

  backup_retention_period = var.environment == "production" ? 7 : 1
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  skip_final_snapshot       = var.environment != "production"
  final_snapshot_identifier = var.environment == "production" ? "${var.project_name}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}" : null

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  performance_insights_enabled    = var.environment == "production"

  tags = {
    Layer = "database"
  }
}

# RDS Security Group
resource "aws_security_group" "rds" {
  name_prefix = "${var.project_name}-rds-"
  description = "Security group for RDS database"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [module.backend_api.security_group_id]
    description     = "Allow access from ECS tasks"
  }

  tags = {
    Name  = "${var.project_name}-rds-sg"
    Layer = "database"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# =========================================
# 4. SECRETS MANAGEMENT
# =========================================

# Database Password
resource "random_password" "db_password" {
  length  = 32
  special = true
}

resource "aws_secretsmanager_secret" "db_password" {
  name_prefix = "${var.project_name}-db-password-"
  description = "Database password for ${var.project_name}"

  tags = {
    Layer = "security"
  }
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db_password.result
}

# JWT Secret
resource "random_password" "jwt_secret" {
  length  = 64
  special = false
}

resource "aws_secretsmanager_secret" "jwt_secret" {
  name_prefix = "${var.project_name}-jwt-secret-"
  description = "JWT secret for ${var.project_name}"

  tags = {
    Layer = "security"
  }
}

resource "aws_secretsmanager_secret_version" "jwt_secret" {
  secret_id     = aws_secretsmanager_secret.jwt_secret.id
  secret_string = random_password.jwt_secret.result
}

# =========================================
# 5. MONITORING & ALERTS
# =========================================

# SNS Topic for Alerts
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-alerts"

  tags = {
    Layer = "monitoring"
  }
}

resource "aws_sns_topic_subscription" "email" {
  count = length(var.alert_emails)

  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_emails[count.index]
}

# CloudWatch Log Group for Application Logs
resource "aws_cloudwatch_log_group" "application" {
  name              = "/aws/${var.project_name}/application"
  retention_in_days = var.environment == "production" ? 90 : 30

  tags = {
    Layer = "monitoring"
  }
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.environment}"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", { stat = "Average" }],
            [".", "RequestCount", { stat = "Sum" }],
            [".", "HTTPCode_Target_5XX_Count", { stat = "Sum" }]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "ALB Metrics"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", { stat = "Average" }],
            [".", "MemoryUtilization", { stat = "Average" }]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "ECS Metrics"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", { stat = "Average" }],
            [".", "DatabaseConnections", { stat = "Sum" }],
            [".", "FreeableMemory", { stat = "Average" }]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "RDS Metrics"
        }
      }
    ]
  })
}

# =========================================
# 6. ROUTE53 DNS (Optional)
# =========================================

data "aws_route53_zone" "main" {
  count = var.domain_name != "" ? 1 : 0

  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "app" {
  count = var.domain_name != "" ? 1 : 0

  zone_id = data.aws_route53_zone.main[0].zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = module.alb.alb_dns_name
    zone_id                = module.alb.alb_zone_id
    evaluate_target_health = true
  }
}

