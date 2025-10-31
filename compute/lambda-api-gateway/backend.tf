# Remote State Backend Configuration

terraform {
  backend "s3" {
    # Configure during init:
    # terraform init -backend-config=backend.hcl
  }
}

# Example backend.hcl:
# bucket         = "my-terraform-state-bucket"
# key            = "production/lambda-api-gateway/terraform.tfstate"
# region         = "us-east-1"
# dynamodb_table = "terraform-state-locks"
# encrypt        = true

