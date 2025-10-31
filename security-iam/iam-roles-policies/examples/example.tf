# Example usage of the IAM Roles & Policies module

# ECS Task Execution Role
module "ecs_execution_role" {
  source = "../"

  environment = "production"
  role_name   = "ecs-task-execution-role"

  trusted_services = ["ecs-tasks.amazonaws.com"]

  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]

  tags = {
    Project = "MyApp"
    Purpose = "ECSExecution"
  }
}

# Lambda Execution Role
module "lambda_role" {
  source = "../"

  environment = "production"
  role_name   = "lambda-api-handler"

  trusted_services = ["lambda.amazonaws.com"]

  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]

  inline_policies = {
    "dynamodb-access" = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:Query"
        ]
        Resource = "arn:aws:dynamodb:*:*:table/users"
      }]
    })
  }

  tags = {
    Project = "MyApp"
  }
}

# EC2 Instance Role with Instance Profile
module "ec2_instance_role" {
  source = "../"

  environment = "production"
  role_name   = "ec2-app-server"

  trusted_services = ["ec2.amazonaws.com"]

  policy_arns = [
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  create_instance_profile = true

  tags = {
    Project = "MyApp"
    Purpose = "AppServer"
  }
}

# Cross-Account Role with MFA
module "cross_account_role" {
  source = "../"

  environment = "production"
  role_name   = "cross-account-admin"

  trusted_account_ids = ["123456789012"]
  require_mfa         = true

  policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess"
  ]

  max_session_duration = 14400  # 4 hours

  tags = {
    Purpose = "CrossAccount"
  }
}

# Custom Application Role
module "app_role" {
  source = "../"

  environment = "production"
  role_name   = "app-backend-role"

  trusted_services = ["ecs-tasks.amazonaws.com"]

  inline_policies = {
    "s3-access" = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::my-app-bucket/*"
      }]
    })
    "secrets-access" = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "arn:aws:secretsmanager:*:*:secret:app/*"
      }]
    })
  }

  permissions_boundary = "arn:aws:iam::123456789012:policy/DeveloperBoundary"

  tags = {
    Project = "MyApp"
    Team    = "Backend"
  }
}

# Outputs
output "ecs_role_arn" {
  value = module.ecs_execution_role.role_arn
}

output "lambda_role_arn" {
  value = module.lambda_role.role_arn
}

output "ec2_instance_profile_name" {
  value = module.ec2_instance_role.instance_profile_name
}

