# Example: Internet Gateway and NAT Gateway Module

# Basic usage with high availability
module "nat_gateway" {
  source = "../"

  vpc_id      = "vpc-12345678"
  name_prefix = "production"
  environment = "production"

  public_subnet_ids  = ["subnet-abc123", "subnet-def456", "subnet-ghi789"]
  private_subnet_ids = ["subnet-111222", "subnet-333444", "subnet-555666"]

  enable_nat_gateway = true
  single_nat_gateway = false # NAT per AZ for HA

  tags = {
    Project = "my-startup"
    Team    = "platform"
  }
}

# Cost-optimized for development
module "nat_gateway_dev" {
  source = "../"

  vpc_id      = "vpc-87654321"
  name_prefix = "dev"
  environment = "dev"

  public_subnet_ids  = ["subnet-aaa111"]
  private_subnet_ids = ["subnet-bbb222"]

  enable_nat_gateway = true
  single_nat_gateway = true # Single NAT for cost savings

  tags = {
    Project = "my-startup"
    Team    = "platform"
  }
}

output "nat_ips" {
  value = module.nat_gateway.nat_gateway_public_ips
}

