# AWS Provider Configuration

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Module      = "lambda-api-gateway"
      Project     = var.project_name
    }
  }
}

