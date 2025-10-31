# Lambda API Gateway Module - Outputs

# API Gateway Outputs
output "api_id" {
  description = "ID of the API Gateway REST API"
  value       = aws_api_gateway_rest_api.main.id
}

output "api_arn" {
  description = "ARN of the API Gateway REST API"
  value       = aws_api_gateway_rest_api.main.arn
}

output "api_endpoint" {
  description = "Invoke URL of the API Gateway"
  value       = aws_api_gateway_stage.main.invoke_url
}

output "api_execution_arn" {
  description = "Execution ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.main.execution_arn
}

output "stage_name" {
  description = "Name of the deployed stage"
  value       = aws_api_gateway_stage.main.stage_name
}

# Custom Domain Outputs
output "custom_domain_name" {
  description = "Custom domain name"
  value       = var.enable_custom_domain ? aws_api_gateway_domain_name.main[0].domain_name : null
}

output "custom_domain_regional_domain_name" {
  description = "Regional domain name for Route53 ALIAS record"
  value       = var.enable_custom_domain ? aws_api_gateway_domain_name.main[0].regional_domain_name : null
}

output "custom_domain_regional_zone_id" {
  description = "Regional zone ID for Route53 ALIAS record"
  value       = var.enable_custom_domain ? aws_api_gateway_domain_name.main[0].regional_zone_id : null
}

# Lambda Function Outputs
output "lambda_function_arns" {
  description = "ARNs of Lambda functions"
  value       = { for k, v in aws_lambda_function.main : k => v.arn }
}

output "lambda_function_names" {
  description = "Names of Lambda functions"
  value       = { for k, v in aws_lambda_function.main : k => v.function_name }
}

output "lambda_function_invoke_arns" {
  description = "Invoke ARNs of Lambda functions"
  value       = { for k, v in aws_lambda_function.main : k => v.invoke_arn }
}

output "lambda_role_arns" {
  description = "ARNs of Lambda IAM roles"
  value       = { for k, v in aws_iam_role.lambda : k => v.arn }
}

# Log Group Outputs
output "log_group_names" {
  description = "Names of CloudWatch Log Groups"
  value       = { for k, v in aws_cloudwatch_log_group.lambda : k => v.name }
}

# API Key Outputs
output "api_key_id" {
  description = "ID of the API key"
  value       = var.enable_api_key ? aws_api_gateway_api_key.main[0].id : null
}

output "api_key_value" {
  description = "Value of the API key (sensitive)"
  value       = var.enable_api_key ? aws_api_gateway_api_key.main[0].value : null
  sensitive   = true
}

output "usage_plan_id" {
  description = "ID of the usage plan"
  value       = var.enable_api_key ? aws_api_gateway_usage_plan.main[0].id : null
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

