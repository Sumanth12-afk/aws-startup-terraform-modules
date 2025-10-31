terraform {
  backend "s3" {
    bucket         = var.state_bucket_name
    key            = "${var.environment}/storage-databases/dynamodb-nosql-table/terraform.tfstate"
    region         = var.aws_region
    dynamodb_table = var.state_lock_table
    encrypt        = true
  }
}

