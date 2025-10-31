# Complete Startup Infrastructure - Outputs

# Networking
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "alb_url" {
  description = "URL of the application"
  value       = "https://${var.domain_name != "" ? var.domain_name : module.alb.alb_dns_name}"
}

# Compute
output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.backend_api.cluster_name
}

output "backend_api_service_name" {
  description = "Name of the backend API ECS service"
  value       = module.backend_api.service_name
}

output "frontend_web_service_name" {
  description = "Name of the frontend web ECS service"
  value       = module.frontend_web.service_name
}

output "lambda_api_endpoint" {
  description = "Endpoint of the serverless API"
  value       = module.lambda_functions.api_endpoint
}

# Database
output "database_endpoint" {
  description = "Endpoint of the RDS database"
  value       = aws_db_instance.main.endpoint
  sensitive   = true
}

output "database_name" {
  description = "Name of the database"
  value       = aws_db_instance.main.db_name
}

# Secrets
output "db_password_secret_arn" {
  description = "ARN of the database password secret"
  value       = aws_secretsmanager_secret.db_password.arn
}

output "jwt_secret_arn" {
  description = "ARN of the JWT secret"
  value       = aws_secretsmanager_secret.jwt_secret.arn
}

# Monitoring
output "cloudwatch_dashboard_url" {
  description = "URL to the CloudWatch dashboard"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for alerts"
  value       = aws_sns_topic.alerts.arn
}

# Cost Estimation
output "estimated_monthly_cost" {
  description = "Estimated monthly cost (approximate)"
  value = var.environment == "production" ? {
    vpc             = "~$100 (3 NAT Gateways)"
    alb             = "~$25"
    ecs_fargate     = "~$150-300 (5 tasks)"
    rds             = "~$100 (db.t4g.medium Multi-AZ)"
    cloudwatch      = "~$20"
    secrets_manager = "~$1"
    total           = "~$396-546/month"
  } : {
    vpc             = "~$35 (1 NAT Gateway)"
    alb             = "~$25"
    ecs_fargate     = "~$60-100 (3 tasks)"
    rds             = "~$15 (db.t4g.micro)"
    cloudwatch      = "~$10"
    secrets_manager = "~$1"
    total           = "~$146-186/month"
  }
}

