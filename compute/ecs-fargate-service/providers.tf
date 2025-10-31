# AWS Provider Configuration

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Module      = "ecs-fargate-service"
      Project     = var.project_name
    }
  }
}

