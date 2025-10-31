terraform {
  backend "s3" {
    bucket         = var.state_bucket_name
    key            = "${var.environment}/storage-databases/s3-static-website/terraform.tfstate"
    region         = var.aws_region
    dynamodb_table = var.state_lock_table
    encrypt        = true
  }
}

