# S3 Bucket Outputs
output "bucket_id" {
  description = "The name of the bucket"
  value       = aws_s3_bucket.website.id
}

output "bucket_arn" {
  description = "The ARN of the bucket"
  value       = aws_s3_bucket.website.arn
}

output "bucket_domain_name" {
  description = "The bucket domain name"
  value       = aws_s3_bucket.website.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "The bucket region-specific domain name"
  value       = aws_s3_bucket.website.bucket_regional_domain_name
}

output "website_endpoint" {
  description = "The website endpoint URL"
  value       = aws_s3_bucket_website_configuration.website.website_endpoint
}

output "website_domain" {
  description = "The domain of the website endpoint"
  value       = aws_s3_bucket_website_configuration.website.website_domain
}

# CloudFront Outputs
output "cloudfront_distribution_id" {
  description = "The identifier for the CloudFront distribution"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.website[0].id : null
}

output "cloudfront_distribution_arn" {
  description = "The ARN of the CloudFront distribution"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.website[0].arn : null
}

output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.website[0].domain_name : null
}

output "cloudfront_hosted_zone_id" {
  description = "The CloudFront Route 53 zone ID"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.website[0].hosted_zone_id : null
}

output "cloudfront_oai_iam_arn" {
  description = "The IAM ARN of the CloudFront Origin Access Identity"
  value       = var.enable_cloudfront ? aws_cloudfront_origin_access_identity.website[0].iam_arn : null
}

# Access Logging Outputs
output "access_log_bucket_id" {
  description = "The name of the access logs bucket"
  value       = var.enable_access_logging ? aws_s3_bucket.access_logs[0].id : null
}

output "access_log_bucket_arn" {
  description = "The ARN of the access logs bucket"
  value       = var.enable_access_logging ? aws_s3_bucket.access_logs[0].arn : null
}

# Deployment Information
output "deployment_url" {
  description = "The primary URL for accessing the website"
  value = var.enable_cloudfront ? (
    var.custom_domain != null ? "https://${var.custom_domain}" : "https://${aws_cloudfront_distribution.website[0].domain_name}"
  ) : "http://${aws_s3_bucket_website_configuration.website.website_endpoint}"
}

output "s3_sync_command" {
  description = "AWS CLI command to sync local files to S3"
  value       = "aws s3 sync ./ s3://${aws_s3_bucket.website.id}/ --delete --cache-control '${var.cache_control}'"
}

output "cloudfront_invalidation_command" {
  description = "AWS CLI command to invalidate CloudFront cache"
  value       = var.enable_cloudfront ? "aws cloudfront create-invalidation --distribution-id ${aws_cloudfront_distribution.website[0].id} --paths '/*'" : null
}

# Security Outputs
output "encryption_enabled" {
  description = "Whether server-side encryption is enabled"
  value       = var.enable_encryption
}

output "versioning_enabled" {
  description = "Whether versioning is enabled"
  value       = var.enable_versioning
}

output "public_access_enabled" {
  description = "Whether public access is enabled"
  value       = var.enable_public_access
}

# Monitoring Outputs
output "metrics_enabled" {
  description = "Whether request metrics are enabled"
  value       = var.enable_metrics
}

output "cloudwatch_alarm_arns" {
  description = "ARNs of CloudWatch alarms"
  value = concat(
    var.enable_cloudfront && var.enable_metrics ? [aws_cloudwatch_metric_alarm.high_4xx_errors[0].arn] : [],
    var.enable_cloudfront && var.enable_metrics ? [aws_cloudwatch_metric_alarm.high_5xx_errors[0].arn] : []
  )
}

