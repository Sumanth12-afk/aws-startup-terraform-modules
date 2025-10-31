# VPC Networking Module - Outputs

# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "vpc_arn" {
  description = "ARN of the VPC"
  value       = aws_vpc.main.arn
}

output "vpc_ipv6_cidr_block" {
  description = "IPv6 CIDR block of the VPC"
  value       = var.enable_ipv6 ? aws_vpc.main.ipv6_cidr_block : null
}

# Internet Gateway Outputs
output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

# Public Subnet Outputs
output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  value       = aws_subnet.public[*].cidr_block
}

output "public_subnet_arns" {
  description = "List of public subnet ARNs"
  value       = aws_subnet.public[*].arn
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

# Private Subnet Outputs
output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  value       = aws_subnet.private[*].cidr_block
}

output "private_subnet_arns" {
  description = "List of private subnet ARNs"
  value       = aws_subnet.private[*].arn
}

output "private_route_table_ids" {
  description = "List of private route table IDs"
  value       = aws_route_table.private[*].id
}

# Database Subnet Outputs
output "database_subnet_ids" {
  description = "List of database subnet IDs"
  value       = var.enable_database_subnets ? aws_subnet.database[*].id : []
}

output "database_subnet_cidrs" {
  description = "List of database subnet CIDR blocks"
  value       = var.enable_database_subnets ? aws_subnet.database[*].cidr_block : []
}

output "database_subnet_group_name" {
  description = "Name of the database subnet group"
  value       = var.enable_database_subnets ? aws_db_subnet_group.main[0].name : null
}

output "database_subnet_group_id" {
  description = "ID of the database subnet group"
  value       = var.enable_database_subnets ? aws_db_subnet_group.main[0].id : null
}

output "database_route_table_id" {
  description = "ID of the database route table"
  value       = var.enable_database_subnets ? aws_route_table.database[0].id : null
}

# NAT Gateway Outputs
output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = var.enable_nat_gateway ? aws_nat_gateway.main[*].id : []
}

output "nat_gateway_public_ips" {
  description = "List of NAT Gateway public IP addresses"
  value       = var.enable_nat_gateway ? aws_eip.nat[*].public_ip : []
}

output "elastic_ip_ids" {
  description = "List of Elastic IP IDs for NAT Gateways"
  value       = var.enable_nat_gateway ? aws_eip.nat[*].id : []
}

# Flow Logs Outputs
output "flow_logs_id" {
  description = "ID of the VPC Flow Logs"
  value       = var.enable_flow_logs ? aws_flow_log.main[0].id : null
}

output "flow_logs_s3_bucket" {
  description = "S3 bucket name for VPC Flow Logs"
  value       = var.enable_flow_logs && var.flow_logs_destination_type == "s3" ? aws_s3_bucket.flow_logs[0].id : null
}

output "flow_logs_cloudwatch_log_group" {
  description = "CloudWatch Log Group name for VPC Flow Logs"
  value       = var.enable_flow_logs && var.flow_logs_destination_type == "cloud-watch-logs" ? aws_cloudwatch_log_group.flow_logs[0].name : null
}

# Availability Zones
output "availability_zones" {
  description = "List of availability zones used"
  value       = var.availability_zones
}

# Default Security Group
output "default_security_group_id" {
  description = "ID of the default security group"
  value       = aws_default_security_group.default.id
}

# DHCP Options
output "dhcp_options_id" {
  description = "ID of the DHCP options set"
  value       = var.enable_custom_dhcp_options ? aws_vpc_dhcp_options.main[0].id : null
}

# Metadata
output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "tags" {
  description = "Tags applied to resources"
  value       = var.tags
}

