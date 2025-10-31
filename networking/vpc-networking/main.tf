# VPC Networking Module - Production-Ready Multi-AZ VPC
# AWS Well-Architected Framework compliant

terraform {
  required_version = ">= 1.5.0"
}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block                       = var.vpc_cidr
  enable_dns_hostnames             = var.enable_dns_hostnames
  enable_dns_support               = var.enable_dns_support
  assign_generated_ipv6_cidr_block = var.enable_ipv6

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-vpc"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# Create Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-igw"
      Environment = var.environment
    }
  )
}

# Create Public Subnets
resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, var.subnet_cidr_newbits, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-public-subnet-${var.availability_zones[count.index]}"
      Environment = var.environment
      Type        = "Public"
      Tier        = "public"
    }
  )
}

# Create Private Subnets
resource "aws_subnet" "private" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, var.subnet_cidr_newbits, count.index + length(var.availability_zones))
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-private-subnet-${var.availability_zones[count.index]}"
      Environment = var.environment
      Type        = "Private"
      Tier        = "private"
    }
  )
}

# Create Database Subnets (isolated private subnets)
resource "aws_subnet" "database" {
  count = var.enable_database_subnets ? length(var.availability_zones) : 0

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, var.subnet_cidr_newbits, count.index + (2 * length(var.availability_zones)))
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-database-subnet-${var.availability_zones[count.index]}"
      Environment = var.environment
      Type        = "Database"
      Tier        = "database"
    }
  )
}

# Create Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-public-rt"
      Environment = var.environment
      Type        = "Public"
    }
  )
}

# Public Route to Internet Gateway
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Create Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.availability_zones)) : 0

  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-nat-eip-${count.index + 1}"
      Environment = var.environment
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# Create NAT Gateways
resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.availability_zones)) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-nat-gw-${var.availability_zones[count.index]}"
      Environment = var.environment
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# Create Private Route Tables
resource "aws_route_table" "private" {
  count = var.enable_nat_gateway ? length(var.availability_zones) : 1

  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name        = var.enable_nat_gateway ? "${var.environment}-private-rt-${var.availability_zones[count.index]}" : "${var.environment}-private-rt"
      Environment = var.environment
      Type        = "Private"
    }
  )
}

# Private Routes to NAT Gateway
resource "aws_route" "private_nat_gateway" {
  count = var.enable_nat_gateway ? length(aws_route_table.private) : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.single_nat_gateway ? aws_nat_gateway.main[0].id : aws_nat_gateway.main[count.index].id
}

# Associate Private Subnets with Private Route Tables
resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = var.enable_nat_gateway ? aws_route_table.private[count.index].id : aws_route_table.private[0].id
}

# Create Database Route Table
resource "aws_route_table" "database" {
  count = var.enable_database_subnets ? 1 : 0

  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-database-rt"
      Environment = var.environment
      Type        = "Database"
    }
  )
}

# Associate Database Subnets with Database Route Table
resource "aws_route_table_association" "database" {
  count = var.enable_database_subnets ? length(aws_subnet.database) : 0

  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database[0].id
}

# Create DB Subnet Group
resource "aws_db_subnet_group" "main" {
  count = var.enable_database_subnets ? 1 : 0

  name       = "${var.environment}-db-subnet-group"
  subnet_ids = aws_subnet.database[*].id

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-db-subnet-group"
      Environment = var.environment
    }
  )
}

# VPC Flow Logs
resource "aws_flow_log" "main" {
  count = var.enable_flow_logs ? 1 : 0

  log_destination_type = var.flow_logs_destination_type
  log_destination      = var.flow_logs_destination_type == "s3" ? aws_s3_bucket.flow_logs[0].arn : aws_cloudwatch_log_group.flow_logs[0].arn
  traffic_type         = var.flow_logs_traffic_type
  vpc_id               = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-vpc-flow-logs"
      Environment = var.environment
    }
  )
}

# S3 Bucket for Flow Logs
resource "aws_s3_bucket" "flow_logs" {
  count = var.enable_flow_logs && var.flow_logs_destination_type == "s3" ? 1 : 0

  bucket = "${var.environment}-vpc-flow-logs-${data.aws_caller_identity.current.account_id}"

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-vpc-flow-logs"
      Environment = var.environment
    }
  )
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "flow_logs" {
  count = var.enable_flow_logs && var.flow_logs_destination_type == "s3" ? 1 : 0

  bucket = aws_s3_bucket.flow_logs[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "flow_logs" {
  count = var.enable_flow_logs && var.flow_logs_destination_type == "s3" ? 1 : 0

  bucket = aws_s3_bucket.flow_logs[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket Lifecycle
resource "aws_s3_bucket_lifecycle_configuration" "flow_logs" {
  count = var.enable_flow_logs && var.flow_logs_destination_type == "s3" ? 1 : 0

  bucket = aws_s3_bucket.flow_logs[0].id

  rule {
    id     = "flow-logs-retention"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = var.flow_logs_retention_days
    }
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "flow_logs" {
  count = var.enable_flow_logs && var.flow_logs_destination_type == "s3" ? 1 : 0

  bucket = aws_s3_bucket.flow_logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CloudWatch Log Group for Flow Logs
resource "aws_cloudwatch_log_group" "flow_logs" {
  count = var.enable_flow_logs && var.flow_logs_destination_type == "cloud-watch-logs" ? 1 : 0

  name              = "/aws/vpc/${var.environment}-flow-logs"
  retention_in_days = var.flow_logs_retention_days

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-vpc-flow-logs"
      Environment = var.environment
    }
  )
}

# IAM Role for Flow Logs (CloudWatch only)
resource "aws_iam_role" "flow_logs" {
  count = var.enable_flow_logs && var.flow_logs_destination_type == "cloud-watch-logs" ? 1 : 0

  name = "${var.environment}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-vpc-flow-logs-role"
      Environment = var.environment
    }
  )
}

# IAM Policy for Flow Logs
resource "aws_iam_role_policy" "flow_logs" {
  count = var.enable_flow_logs && var.flow_logs_destination_type == "cloud-watch-logs" ? 1 : 0

  name = "${var.environment}-vpc-flow-logs-policy"
  role = aws_iam_role.flow_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Default Security Group - Deny All
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-default-sg-deny-all"
      Environment = var.environment
    }
  )
}

# DHCP Options
resource "aws_vpc_dhcp_options" "main" {
  count = var.enable_custom_dhcp_options ? 1 : 0

  domain_name         = var.dhcp_options_domain_name
  domain_name_servers = var.dhcp_options_domain_name_servers

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-dhcp-options"
      Environment = var.environment
    }
  )
}

# Associate DHCP Options with VPC
resource "aws_vpc_dhcp_options_association" "main" {
  count = var.enable_custom_dhcp_options ? 1 : 0

  vpc_id          = aws_vpc.main.id
  dhcp_options_id = aws_vpc_dhcp_options.main[0].id
}

# Data source for current AWS account
data "aws_caller_identity" "current" {}

