# Lambda API Gateway Module - Serverless REST API

terraform {
  required_version = ">= 1.5.0"
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ========================================
# API Gateway REST API
# ========================================

resource "aws_api_gateway_rest_api" "main" {
  name        = var.api_name
  description = var.api_description

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = merge(
    var.tags,
    {
      Name        = var.api_name
      Environment = var.environment
    }
  )
}

# ========================================
# Lambda Functions
# ========================================

# IAM Role for Lambda Functions
resource "aws_iam_role" "lambda" {
  for_each = var.lambda_functions

  name = "${var.api_name}-${each.key}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = merge(
    var.tags,
    {
      Name        = "${var.api_name}-${each.key}-lambda-role"
      Environment = var.environment
    }
  )
}

# Attach basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  for_each = var.lambda_functions

  role       = aws_iam_role.lambda[each.key].name
  policy_arn = var.enable_vpc ? "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole" : "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# X-Ray policy
resource "aws_iam_role_policy_attachment" "lambda_xray" {
  for_each = var.enable_xray ? var.lambda_functions : {}

  role       = aws_iam_role.lambda[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "lambda" {
  for_each = var.lambda_functions

  name              = "/aws/lambda/${var.api_name}-${each.key}"
  retention_in_days = var.log_retention_days

  tags = merge(
    var.tags,
    {
      Name        = "${var.api_name}-${each.key}-logs"
      Environment = var.environment
    }
  )
}

# Lambda Functions
resource "aws_lambda_function" "main" {
  for_each = var.lambda_functions

  function_name    = "${var.api_name}-${each.key}"
  role             = aws_iam_role.lambda[each.key].arn
  handler          = each.value.handler
  runtime          = each.value.runtime
  filename         = each.value.filename
  source_code_hash = each.value.source_code_hash
  memory_size      = each.value.memory_size
  timeout          = each.value.timeout
  layers           = var.lambda_layer_arns

  environment {
    variables = each.value.environment_variables
  }

  dynamic "vpc_config" {
    for_each = var.enable_vpc ? [1] : []
    content {
      subnet_ids         = var.vpc_subnet_ids
      security_group_ids = var.vpc_security_group_ids
    }
  }

  dynamic "tracing_config" {
    for_each = var.enable_xray ? [1] : []
    content {
      mode = "Active"
    }
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.api_name}-${each.key}"
      Environment = var.environment
    }
  )

  depends_on = [aws_cloudwatch_log_group.lambda]
}

# ========================================
# API Gateway Resources and Methods
# ========================================

# Create resources for each unique path
locals {
  # Extract unique paths from lambda functions
  unique_paths = distinct([for k, v in var.lambda_functions : v.http_path])
  
  # Create map of path to resource
  path_resources = {
    for path in local.unique_paths :
    path => {
      parts = split("/", trimprefix(path, "/"))
    }
  }
}

# Root path parts
resource "aws_api_gateway_resource" "paths" {
  for_each = local.path_resources

  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = length(each.value.parts) > 0 ? each.value.parts[0] : ""
}

# HTTP Methods
resource "aws_api_gateway_method" "main" {
  for_each = var.lambda_functions

  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.paths[each.value.http_path].id
  http_method   = each.value.http_method
  authorization = each.value.authorization
  api_key_required = var.enable_api_key
}

# Lambda Integration
resource "aws_api_gateway_integration" "lambda" {
  for_each = var.lambda_functions

  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.paths[each.value.http_path].id
  http_method             = aws_api_gateway_method.main[each.key].http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.main[each.key].invoke_arn
}

# Lambda permissions
resource "aws_lambda_permission" "api_gateway" {
  for_each = var.lambda_functions

  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main[each.key].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

# CORS Configuration
resource "aws_api_gateway_method" "options" {
  for_each = var.enable_cors ? local.path_resources : {}

  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.paths[each.key].id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options" {
  for_each = var.enable_cors ? local.path_resources : {}

  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.paths[each.key].id
  http_method = aws_api_gateway_method.options[each.key].http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options" {
  for_each = var.enable_cors ? local.path_resources : {}

  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.paths[each.key].id
  http_method = aws_api_gateway_method.options[each.key].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options" {
  for_each = var.enable_cors ? local.path_resources : {}

  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.paths[each.key].id
  http_method = aws_api_gateway_method.options[each.key].http_method
  status_code = aws_api_gateway_method_response.options[each.key].status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'${join(",", var.cors_allow_origins)}'"
  }
}

# ========================================
# API Gateway Deployment
# ========================================

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.paths,
      aws_api_gateway_method.main,
      aws_api_gateway_integration.lambda,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.lambda,
    aws_api_gateway_integration.options
  ]
}

resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = var.stage_name

  xray_tracing_enabled = var.enable_xray

  tags = merge(
    var.tags,
    {
      Name        = "${var.api_name}-${var.stage_name}"
      Environment = var.environment
    }
  )
}

# ========================================
# API Key and Usage Plan (Optional)
# ========================================

resource "aws_api_gateway_api_key" "main" {
  count = var.enable_api_key ? 1 : 0

  name    = "${var.api_name}-api-key"
  enabled = true

  tags = merge(
    var.tags,
    {
      Name        = "${var.api_name}-api-key"
      Environment = var.environment
    }
  )
}

resource "aws_api_gateway_usage_plan" "main" {
  count = var.enable_api_key ? 1 : 0

  name = "${var.api_name}-usage-plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.main.id
    stage  = aws_api_gateway_stage.main.stage_name
  }

  quota_settings {
    limit  = 10000
    period = "MONTH"
  }

  throttle_settings {
    burst_limit = 100
    rate_limit  = 50
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.api_name}-usage-plan"
      Environment = var.environment
    }
  )
}

resource "aws_api_gateway_usage_plan_key" "main" {
  count = var.enable_api_key ? 1 : 0

  key_id        = aws_api_gateway_api_key.main[0].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.main[0].id
}

# ========================================
# Custom Domain (Optional)
# ========================================

resource "aws_api_gateway_domain_name" "main" {
  count = var.enable_custom_domain ? 1 : 0

  domain_name              = var.custom_domain_name
  regional_certificate_arn = var.certificate_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = merge(
    var.tags,
    {
      Name        = var.custom_domain_name
      Environment = var.environment
    }
  )
}

resource "aws_api_gateway_base_path_mapping" "main" {
  count = var.enable_custom_domain ? 1 : 0

  api_id      = aws_api_gateway_rest_api.main.id
  stage_name  = aws_api_gateway_stage.main.stage_name
  domain_name = aws_api_gateway_domain_name.main[0].domain_name
}

# ========================================
# CloudWatch Alarms
# ========================================

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  for_each = var.enable_cloudwatch_alarms ? var.lambda_functions : {}

  alarm_name          = "${var.api_name}-${each.key}-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Lambda function errors"
  alarm_actions       = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

  dimensions = {
    FunctionName = aws_lambda_function.main[each.key].function_name
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.api_name}-${each.key}-errors-alarm"
      Environment = var.environment
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "api_5xx" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${var.api_name}-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "API Gateway 5XX errors"
  alarm_actions       = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

  dimensions = {
    ApiName = aws_api_gateway_rest_api.main.name
    Stage   = aws_api_gateway_stage.main.stage_name
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.api_name}-5xx-errors-alarm"
      Environment = var.environment
    }
  )
}

