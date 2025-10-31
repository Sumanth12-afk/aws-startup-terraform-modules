variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile"
  type        = string
  default     = "default"
}

variable "origin_domain_name" {
  description = "Origin domain name"
  type        = string
}

variable "origin_id" {
  description = "Origin ID"
  type        = string
  default     = "primary"
}

variable "origin_type" {
  description = "Origin type (s3 or custom)"
  type        = string
  default     = "s3"
}

variable "origin_protocol_policy" {
  description = "Origin protocol policy"
  type        = string
  default     = "https-only"
}

variable "price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_100"
}

variable "default_root_object" {
  description = "Default root object"
  type        = string
  default     = "index.html"
}

variable "aliases" {
  description = "Custom domain aliases"
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN"
  type        = string
  default     = null
}

variable "enable_ipv6" {
  description = "Enable IPv6"
  type        = bool
  default     = true
}

variable "allowed_methods" {
  description = "Allowed HTTP methods"
  type        = list(string)
  default     = ["GET", "HEAD", "OPTIONS"]
}

variable "cached_methods" {
  description = "Cached HTTP methods"
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "forward_query_string" {
  description = "Forward query strings"
  type        = bool
  default     = false
}

variable "forward_headers" {
  description = "Headers to forward"
  type        = list(string)
  default     = []
}

variable "forward_cookies" {
  description = "Cookie forwarding (none, whitelist, all)"
  type        = string
  default     = "none"
}

variable "min_ttl" {
  description = "Minimum TTL"
  type        = number
  default     = 0
}

variable "default_ttl" {
  description = "Default TTL"
  type        = number
  default     = 3600
}

variable "max_ttl" {
  description = "Maximum TTL"
  type        = number
  default     = 86400
}

variable "enable_compression" {
  description = "Enable compression"
  type        = bool
  default     = true
}

variable "geo_restriction_type" {
  description = "Geo restriction type (none, whitelist, blacklist)"
  type        = string
  default     = "none"
}

variable "geo_restriction_locations" {
  description = "Geo restriction locations"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

