# Example: Lambda API Gateway Module Usage

# Example Lambda function code (save as lambda/get-users/index.js)
# exports.handler = async (event) => {
#   return {
#     statusCode: 200,
#     headers: { 'Content-Type': 'application/json' },
#     body: JSON.stringify({ users: [{id: 1, name: 'John'}] })
#   };
# };

# Example 1: Basic REST API
module "api_basic" {
  source = "../"

  aws_region   = "us-east-1"
  environment  = "production"
  project_name = "my-startup"

  api_name   = "user-api"
  stage_name = "v1"

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

    get_user_by_id = {
      handler          = "index.handler"
      runtime          = "nodejs20.x"
      filename         = "lambda/get-user.zip"
      source_code_hash = filebase64sha256("lambda/get-user.zip")
      memory_size      = 512
      timeout          = 30
      environment_variables = {
        TABLE_NAME = "users"
      }
      http_method   = "GET"
      http_path     = "/user"
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

  enable_cors        = true
  cors_allow_origins = ["*"]
  enable_xray        = true
}

# Example 2: API with Custom Domain and API Key
module "api_advanced" {
  source = "../"

  aws_region   = "us-east-1"
  environment  = "production"
  project_name = "my-startup"

  api_name        = "public-api"
  api_description = "Public API for My Startup"
  stage_name      = "v1"

  # Custom Domain
  enable_custom_domain = true
  custom_domain_name   = "api.myapp.com"
  certificate_arn      = "arn:aws:acm:us-east-1:123456789012:certificate/xxx"

  # API Key & Usage Plans
  enable_api_key = true

  # CORS
  enable_cors        = true
  cors_allow_origins = ["https://myapp.com", "https://www.myapp.com"]

  # Lambda Functions
  lambda_functions = {
    products = {
      handler          = "index.handler"
      runtime          = "python3.12"
      filename         = "lambda/products.zip"
      source_code_hash = filebase64sha256("lambda/products.zip")
      memory_size      = 1024
      timeout          = 60
      environment_variables = {
        DB_HOST        = "db.internal.example.com"
        CACHE_ENDPOINT = "redis.internal.example.com"
      }
      http_method   = "GET"
      http_path     = "/products"
      authorization = "NONE"
    }

    orders = {
      handler          = "index.handler"
      runtime          = "python3.12"
      filename         = "lambda/orders.zip"
      source_code_hash = filebase64sha256("lambda/orders.zip")
      memory_size      = 1024
      timeout          = 60
      environment_variables = {
        PAYMENT_API_URL = "https://payments.example.com"
      }
      http_method   = "POST"
      http_path     = "/orders"
      authorization = "AWS_IAM"
    }
  }

  # Monitoring
  enable_xray              = true
  enable_cloudwatch_alarms = true
  alarm_sns_topic_arn      = aws_sns_topic.alerts.arn

  tags = {
    Team       = "backend"
    CostCenter = "engineering"
  }
}

# Route53 record for custom domain
resource "aws_route53_record" "api" {
  zone_id = "Z1234567890ABC"
  name    = "api.myapp.com"
  type    = "A"

  alias {
    name                   = module.api_advanced.custom_domain_regional_domain_name
    zone_id                = module.api_advanced.custom_domain_regional_zone_id
    evaluate_target_health = false
  }
}

# SNS topic for alarms
resource "aws_sns_topic" "alerts" {
  name = "api-alerts"

  tags = {
    Environment = "production"
  }
}

# Example 3: VPC-Connected Lambda (for database access)
module "api_vpc" {
  source = "../"

  aws_region   = "us-east-1"
  environment  = "production"
  project_name = "my-startup"

  api_name   = "internal-api"
  stage_name = "v1"

  # VPC Configuration
  enable_vpc             = true
  vpc_subnet_ids         = ["subnet-abc123", "subnet-def456"]
  vpc_security_group_ids = ["sg-lambda123"]

  lambda_functions = {
    db_query = {
      handler          = "index.handler"
      runtime          = "nodejs20.x"
      filename         = "lambda/db-query.zip"
      source_code_hash = filebase64sha256("lambda/db-query.zip")
      memory_size      = 1024
      timeout          = 60
      environment_variables = {
        RDS_HOST     = "mydb.abc123.us-east-1.rds.amazonaws.com"
        RDS_DATABASE = "myapp"
      }
      http_method   = "GET"
      http_path     = "/data"
      authorization = "AWS_IAM"
    }
  }

  enable_cors = false # Internal API
  enable_xray = true
}

# Example 4: Python API with Multiple Endpoints
module "api_python" {
  source = "../"

  aws_region   = "us-east-1"
  environment  = "production"
  project_name = "data-platform"

  api_name        = "analytics-api"
  api_description = "Data Analytics API"
  stage_name      = "prod"

  lambda_functions = {
    analytics_dashboard = {
      handler          = "app.lambda_handler"
      runtime          = "python3.12"
      filename         = "lambda/analytics.zip"
      source_code_hash = filebase64sha256("lambda/analytics.zip")
      memory_size      = 2048
      timeout          = 300
      environment_variables = {
        S3_BUCKET       = "my-data-bucket"
        ATHENA_DATABASE = "analytics_db"
        RESULT_BUCKET   = "query-results"
      }
      http_method   = "GET"
      http_path     = "/analytics"
      authorization = "AWS_IAM"
    }

    reports = {
      handler          = "app.lambda_handler"
      runtime          = "python3.12"
      filename         = "lambda/reports.zip"
      source_code_hash = filebase64sha256("lambda/reports.zip")
      memory_size      = 1024
      timeout          = 180
      environment_variables = {
        REPORT_BUCKET = "my-reports-bucket"
      }
      http_method   = "POST"
      http_path     = "/reports"
      authorization = "AWS_IAM"
    }
  }

  # Lambda layers for shared dependencies
  lambda_layer_arns = [
    "arn:aws:lambda:us-east-1:123456789012:layer:pandas-layer:1",
    "arn:aws:lambda:us-east-1:123456789012:layer:numpy-layer:1"
  ]

  enable_xray              = true
  log_retention_days       = 90
  enable_cloudwatch_alarms = true
}

# Outputs
output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = module.api_basic.api_endpoint
}

output "api_custom_domain" {
  description = "Custom domain for advanced API"
  value       = module.api_advanced.custom_domain_name
}

output "lambda_functions" {
  description = "Lambda function ARNs"
  value       = module.api_basic.lambda_function_arns
}

output "api_key" {
  description = "API key for authenticated access"
  value       = module.api_advanced.api_key_value
  sensitive   = true
}

# Bootstrap resources for remote state
resource "aws_s3_bucket" "terraform_state" {
  bucket = "my-company-terraform-state"

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "shared"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-state-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform State Locks"
    Environment = "shared"
  }
}

