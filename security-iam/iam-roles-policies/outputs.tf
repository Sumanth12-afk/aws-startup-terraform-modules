# IAM Role Outputs
output "role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.main.arn
}

output "role_name" {
  description = "Name of the IAM role"
  value       = aws_iam_role.main.name
}

output "role_id" {
  description = "ID of the IAM role"
  value       = aws_iam_role.main.id
}

output "role_unique_id" {
  description = "Unique ID of the IAM role"
  value       = aws_iam_role.main.unique_id
}

# Instance Profile Outputs
output "instance_profile_arn" {
  description = "ARN of the instance profile"
  value       = var.create_instance_profile ? aws_iam_instance_profile.main[0].arn : null
}

output "instance_profile_name" {
  description = "Name of the instance profile"
  value       = var.create_instance_profile ? aws_iam_instance_profile.main[0].name : null
}

# Policy Attachments
output "attached_policy_arns" {
  description = "List of attached policy ARNs"
  value       = var.policy_arns
}

output "inline_policy_names" {
  description = "List of inline policy names"
  value       = keys(var.inline_policies)
}

