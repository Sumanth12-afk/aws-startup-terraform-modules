# AWS Provider Configuration

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Module      = "rds-postgres-database"
      Project     = var.project_name
    }
  }
}

