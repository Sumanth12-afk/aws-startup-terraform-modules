# VPC Networking Module - Input Variables

# Environment Configuration
variable "environment" {
  description = "Environment name (e.g., dev, staging, production)"
  type        = string

  validation {
    condition     = can(regex("^(dev|staging|production|prod)$", var.environment))
    error_message = "Environment must be dev, staging, or production/prod."
  }
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "List of availability zones for subnet creation"
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least 2 availability zones are required for high availability."
  }
}

variable "subnet_cidr_newbits" {
  description = "Number of additional bits to use for subnet CIDR calculation"
  type        = number
  default     = 8

  validation {
    condition     = var.subnet_cidr_newbits >= 4 && var.subnet_cidr_newbits <= 16
    error_message = "Subnet CIDR newbits must be between 4 and 16."
  }
}

# DNS Configuration
variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "enable_ipv6" {
  description = "Enable IPv6 support in the VPC"
  type        = bool
  default     = false
}

# NAT Gateway Configuration
variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnet internet access"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway for all AZs (cost optimization for non-prod)"
  type        = bool
  default     = false
}

# Database Subnets
variable "enable_database_subnets" {
  description = "Create dedicated database subnets (isolated from application subnets)"
  type        = bool
  default     = true
}

# VPC Flow Logs
variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs for network traffic analysis"
  type        = bool
  default     = true
}

variable "flow_logs_destination_type" {
  description = "Type of destination for VPC Flow Logs (cloud-watch-logs or s3)"
  type        = string
  default     = "s3"

  validation {
    condition     = contains(["cloud-watch-logs", "s3"], var.flow_logs_destination_type)
    error_message = "Flow logs destination type must be cloud-watch-logs or s3."
  }
}

variable "flow_logs_traffic_type" {
  description = "Type of traffic to capture in flow logs (ACCEPT, REJECT, or ALL)"
  type        = string
  default     = "ALL"

  validation {
    condition     = contains(["ACCEPT", "REJECT", "ALL"], var.flow_logs_traffic_type)
    error_message = "Flow logs traffic type must be ACCEPT, REJECT, or ALL."
  }
}

variable "flow_logs_retention_days" {
  description = "Number of days to retain flow logs"
  type        = number
  default     = 90

  validation {
    condition     = contains([0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.flow_logs_retention_days)
    error_message = "Flow logs retention days must be a valid CloudWatch Logs retention period."
  }
}

# DHCP Options
variable "enable_custom_dhcp_options" {
  description = "Enable custom DHCP options for the VPC"
  type        = bool
  default     = false
}

variable "dhcp_options_domain_name" {
  description = "Domain name for DHCP options"
  type        = string
  default     = ""
}

variable "dhcp_options_domain_name_servers" {
  description = "List of domain name servers for DHCP options"
  type        = list(string)
  default     = ["AmazonProvidedDNS"]
}

# Tags
variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}

