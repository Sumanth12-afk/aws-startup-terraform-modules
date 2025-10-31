# Example Terraform Variables for Lambda API Gateway

# AWS Configuration
aws_region        = "us-east-1"
state_bucket_name = "my-company-terraform-state"
state_lock_table  = "terraform-state-locks"
environment       = "production"
project_name      = "my-startup"

# API Gateway Configuration
api_name        = "my-api"
api_description = "My Startup API"
stage_name      = "v1"

# CORS Configuration
enable_cors        = true
cors_allow_origins = ["https://myapp.com", "https://www.myapp.com"]

# API Key (optional)
enable_api_key = false

# Custom Domain (optional)
enable_custom_domain = true
custom_domain_name   = "api.myapp.com"
certificate_arn      = "arn:aws:acm:us-east-1:123456789012:certificate/xxx"

# Lambda Functions
lambda_functions = {
  get_users = {
    handler          = "index.handler"
    runtime          = "nodejs20.x"
    filename         = "lambda/get-users.zip"
    source_code_hash = filebase64sha256("lambda/get-users.zip")
    memory_size      = 512
    timeout          = 30
    environment_variables = {
      TABLE_NAME = "users"
      LOG_LEVEL  = "info"
    }
    http_method   = "GET"
    http_path     = "/users"
    authorization = "NONE"
  }

  create_user = {
    handler          = "index.handler"
    runtime          = "nodejs20.x"
    filename         = "lambda/create-user.zip"
    source_code_hash = filebase64sha256("lambda/create-user.zip")
    memory_size      = 512
    timeout          = 30
    environment_variables = {
      TABLE_NAME = "users"
    }
    http_method   = "POST"
    http_path     = "/users"
    authorization = "AWS_IAM"
  }
}

# Lambda Layers
lambda_layer_arns = []

# VPC Configuration (if Lambda needs VPC access)
enable_vpc             = false
vpc_subnet_ids         = []
vpc_security_group_ids = []

# Monitoring
enable_xray              = true
log_retention_days       = 30
enable_cloudwatch_alarms = true
alarm_sns_topic_arn      = "arn:aws:sns:us-east-1:123456789012:alerts"

# Tags
tags = {
  Team       = "backend"
  CostCenter = "engineering"
}

