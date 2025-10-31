resource "aws_ssm_parameter" "parameters" {
  for_each = var.parameters

  name        = "/${var.environment}/${each.key}"
  description = each.value.description
  type        = each.value.type
  value       = each.value.value
  tier        = each.value.tier
  key_id      = each.value.type == "SecureString" ? var.kms_key_id : null

  tags = merge(var.tags, {
    Name        = each.key
    Environment = var.environment
  })
}

