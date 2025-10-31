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

variable "domain_name" {
  description = "Domain name for hosted zone"
  type        = string
}

variable "a_records" {
  description = "A records to create"
  type = map(object({
    ttl     = number
    records = list(string)
  }))
  default = {}
}

variable "cname_records" {
  description = "CNAME records to create"
  type = map(object({
    ttl    = number
    record = string
  }))
  default = {}
}

variable "mx_records" {
  description = "MX records"
  type        = list(string)
  default     = []
}

variable "txt_records" {
  description = "TXT records to create"
  type = map(object({
    ttl     = number
    records = list(string)
  }))
  default = {}
}

variable "alias_records" {
  description = "Alias records to create"
  type = map(object({
    type                   = string
    target                 = string
    zone_id                = string
    evaluate_target_health = bool
  }))
  default = {}
}

variable "health_checks" {
  description = "Health checks to create"
  type = map(object({
    fqdn              = string
    port              = number
    type              = string
    resource_path     = string
    failure_threshold = number
    request_interval  = number
  }))
  default = {}
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

