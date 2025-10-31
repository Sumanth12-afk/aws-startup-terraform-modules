# Internet Gateway and NAT Gateway Module
# Standalone module for adding internet connectivity to existing VPC

terraform {
  required_version = ">= 1.5.0"
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name        = "${var.name_prefix}-igw"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.public_subnet_ids)) : 0

  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name        = "${var.name_prefix}-nat-eip-${count.index + 1}"
      Environment = var.environment
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# NAT Gateways
resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.public_subnet_ids)) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = var.public_subnet_ids[count.index]

  tags = merge(
    var.tags,
    {
      Name        = "${var.name_prefix}-nat-gw-${count.index + 1}"
      Environment = var.environment
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name        = "${var.name_prefix}-public-rt"
      Environment = var.environment
    }
  )
}

# Route to Internet Gateway
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_ids)

  subnet_id      = var.public_subnet_ids[count.index]
  route_table_id = aws_route_table.public.id
}

# Private Route Tables
resource "aws_route_table" "private" {
  count = var.enable_nat_gateway ? length(var.private_subnet_ids) : 0

  vpc_id = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name        = "${var.name_prefix}-private-rt-${count.index + 1}"
      Environment = var.environment
    }
  )
}

# Routes to NAT Gateway
resource "aws_route" "private_nat_gateway" {
  count = var.enable_nat_gateway ? length(var.private_subnet_ids) : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.single_nat_gateway ? aws_nat_gateway.main[0].id : aws_nat_gateway.main[count.index].id
}

# Associate private subnets with private route tables
resource "aws_route_table_association" "private" {
  count = var.enable_nat_gateway ? length(var.private_subnet_ids) : 0

  subnet_id      = var.private_subnet_ids[count.index]
  route_table_id = aws_route_table.private[count.index].id
}

