# Environment Configuration
environment = "production"
aws_region  = "us-east-1"
aws_profile = "default"

# Remote State Configuration (uncomment for production)
# state_bucket_name = "my-terraform-state-bucket"
# state_lock_table  = "terraform-state-lock"

# IAM Role Configuration
role_name        = "ecs-task-execution-role"
role_description = "ECS task execution role with ECR and CloudWatch permissions"

max_session_duration = 3600

# Trust Relationships
trusted_services = [
  "ecs-tasks.amazonaws.com"
]

# Optional: Cross-account access
# trusted_account_ids = ["123456789012"]
# require_mfa         = true

# Managed Policies
policy_arns = [
  "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
  "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
]

# Inline Policies (optional)
inline_policies = {}
# inline_policies = {
#   "s3-access" = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Action = [
#         "s3:GetObject",
#         "s3:ListBucket"
#       ]
#       Resource = [
#         "arn:aws:s3:::my-bucket",
#         "arn:aws:s3:::my-bucket/*"
#       ]
#     }]
#   })
# }

# Instance Profile (for EC2)
create_instance_profile = false

# Permissions Boundary (optional)
# permissions_boundary = "arn:aws:iam::123456789012:policy/DeveloperBoundary"

# Path
path = "/"

# Tags
tags = {
  Project    = "MyApp"
  Owner      = "DevOps Team"
  CostCenter = "Engineering"
}

