# Complete Startup Infrastructure - Example Values
# Copy this file to production.tfvars and customize

aws_region   = "us-east-1"
environment  = "production"
project_name = "my-startup"

# Networking
vpc_cidr           = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

# SSL Certificate
certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/your-cert-id"
domain_name     = "app.example.com"

# Container Images (replace with your ECR images)
backend_image  = "123456789012.dkr.ecr.us-east-1.amazonaws.com/backend-api:latest"
frontend_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/frontend-web:latest"

# Cost Optimization
enable_fargate_spot = true # 70% cost savings

# Database
database_name     = "myapp_production"
database_username = "dbadmin"

# Monitoring
alert_emails = [
  "devops@example.com",
  "alerts@example.com"
]

