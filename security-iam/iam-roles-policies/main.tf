# Data Sources
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition

  # Build assume role policy document
  assume_role_principals = concat(
    [for service in var.trusted_services : {
      type        = "Service"
      identifiers = [service]
    }],
    [for role_arn in var.trusted_role_arns : {
      type        = "AWS"
      identifiers = [role_arn]
    }],
    [for account_id in var.trusted_account_ids : {
      type        = "AWS"
      identifiers = ["arn:${local.partition}:iam::${account_id}:root"]
    }]
  )

  common_tags = merge(
    var.tags,
    {
      Name        = var.role_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Module      = "iam-roles-policies"
    }
  )
}

#---------------------------------------------------------------
# IAM Role
#---------------------------------------------------------------

resource "aws_iam_role" "main" {
  name                 = var.role_name
  description          = var.role_description
  max_session_duration = var.max_session_duration
  path                 = var.path
  permissions_boundary = var.permissions_boundary

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      for principal in local.assume_role_principals : {
        Effect = "Allow"
        Principal = {
          (principal.type) = principal.identifiers
        }
        Action = "sts:AssumeRole"
        Condition = var.require_mfa ? {
          Bool = {
            "aws:MultiFactorAuthPresent" = "true"
          }
        } : null
      }
    ]
  })

  tags = local.common_tags
}

#---------------------------------------------------------------
# Attach Managed Policies
#---------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "managed_policies" {
  count      = length(var.policy_arns)
  role       = aws_iam_role.main.name
  policy_arn = var.policy_arns[count.index]
}

#---------------------------------------------------------------
# Inline Policies
#---------------------------------------------------------------

resource "aws_iam_role_policy" "inline_policies" {
  for_each = var.inline_policies

  name   = each.key
  role   = aws_iam_role.main.id
  policy = each.value
}

#---------------------------------------------------------------
# Instance Profile (for EC2)
#---------------------------------------------------------------

resource "aws_iam_instance_profile" "main" {
  count = var.create_instance_profile ? 1 : 0

  name = var.role_name
  role = aws_iam_role.main.name
  path = var.path

  tags = local.common_tags
}

