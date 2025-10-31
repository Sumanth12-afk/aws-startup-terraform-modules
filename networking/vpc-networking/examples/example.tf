# Example: VPC Networking Module Usage

# Production-Grade Multi-AZ VPC with NAT Gateway in Each AZ
module "vpc_production" {
  source = "../"

  environment        = "production"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

  # Enable production features
  enable_nat_gateway         = true
  single_nat_gateway         = false # High availability - NAT per AZ
  enable_database_subnets    = true
  enable_flow_logs           = true
  flow_logs_destination_type = "s3"

  tags = {
    Project     = "my-startup"
    Team        = "platform"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

# Cost-Optimized Development VPC with Single NAT Gateway
module "vpc_development" {
  source = "../"

  environment        = "dev"
  vpc_cidr           = "10.1.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]

  # Cost optimization for dev environment
  enable_nat_gateway      = true
  single_nat_gateway      = true # Single NAT Gateway for cost savings
  enable_database_subnets = true
  enable_flow_logs        = false # Disabled for cost savings

  tags = {
    Project     = "my-startup"
    Team        = "platform"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

# Staging VPC with IPv6 and Custom DHCP Options
module "vpc_staging" {
  source = "../"

  environment        = "staging"
  vpc_cidr           = "10.2.0.0/16"
  availability_zones = ["us-west-2a", "us-west-2b"]

  # Advanced networking features
  enable_nat_gateway      = true
  single_nat_gateway      = false
  enable_database_subnets = true
  enable_flow_logs        = true
  enable_ipv6             = true

  # Custom DHCP options
  enable_custom_dhcp_options       = true
  dhcp_options_domain_name         = "staging.internal.example.com"
  dhcp_options_domain_name_servers = ["AmazonProvidedDNS"]

  # Flow logs configuration
  flow_logs_destination_type = "cloud-watch-logs"
  flow_logs_traffic_type     = "ALL"
  flow_logs_retention_days   = 30

  tags = {
    Project     = "my-startup"
    Team        = "platform"
    Environment = "staging"
    ManagedBy   = "Terraform"
  }
}

# Minimal VPC for Testing (No NAT Gateway)
module "vpc_testing" {
  source = "../"

  environment        = "dev"
  vpc_cidr           = "10.3.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]

  # Minimal configuration for testing
  enable_nat_gateway      = false
  enable_database_subnets = false
  enable_flow_logs        = false

  tags = {
    Project     = "my-startup"
    Team        = "platform"
    Environment = "testing"
    ManagedBy   = "Terraform"
    Purpose     = "integration-testing"
  }
}

# Outputs
output "production_vpc_id" {
  description = "Production VPC ID"
  value       = module.vpc_production.vpc_id
}

output "production_public_subnets" {
  description = "Production public subnet IDs"
  value       = module.vpc_production.public_subnet_ids
}

output "production_private_subnets" {
  description = "Production private subnet IDs"
  value       = module.vpc_production.private_subnet_ids
}

output "production_nat_gateway_ips" {
  description = "Production NAT Gateway public IPs"
  value       = module.vpc_production.nat_gateway_public_ips
}

output "dev_vpc_id" {
  description = "Development VPC ID"
  value       = module.vpc_development.vpc_id
}

output "staging_vpc_id" {
  description = "Staging VPC ID"
  value       = module.vpc_staging.vpc_id
}

