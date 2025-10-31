# Remote State Backend Configuration

terraform {
  backend "s3" {
    # Configure via: terraform init -backend-config=backend.hcl
  }
}

# Example backend.hcl:
# bucket         = "my-terraform-state-bucket"
# key            = "production/rds-postgres/terraform.tfstate"
# region         = "us-east-1"
# dynamodb_table = "terraform-state-locks"
# encrypt        = true

