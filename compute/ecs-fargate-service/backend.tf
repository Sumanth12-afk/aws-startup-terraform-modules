# Remote State Backend Configuration
# This uses S3 for state storage and DynamoDB for state locking

terraform {
  backend "s3" {
    # These values should be configured during terraform init:
    # terraform init \
    #   -backend-config="bucket=my-terraform-state-bucket" \
    #   -backend-config="key=production/ecs-fargate-service/terraform.tfstate" \
    #   -backend-config="region=us-east-1" \
    #   -backend-config="dynamodb_table=terraform-state-locks" \
    #   -backend-config="encrypt=true"

    # Or use a backend.hcl file:
    # terraform init -backend-config=backend.hcl
  }
}

# Example backend.hcl file:
# bucket         = "my-terraform-state-bucket"
# key            = "production/ecs-fargate-service/terraform.tfstate"
# region         = "us-east-1"
# dynamodb_table = "terraform-state-locks"
# encrypt        = true

