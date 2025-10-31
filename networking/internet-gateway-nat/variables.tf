# Internet Gateway and NAT Gateway Module - Variables

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "main"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for NAT Gateways"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs that need NAT Gateway access"
  type        = list(string)
  default     = []
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnet internet access"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use single NAT Gateway for cost optimization"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

