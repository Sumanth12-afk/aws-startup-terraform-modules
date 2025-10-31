# Lambda API Gateway Module

**Production-ready serverless REST API with AWS Lambda and API Gateway.**

Build scalable, cost-effective REST APIs without managing servers. This module creates a complete serverless API with Lambda functions, API Gateway, optional custom domains, and comprehensive monitoring.

---

## 📋 Features

✅ **Serverless Architecture**: Pay only for requests, zero idle costs  
✅ **API Gateway Integration**: RESTful API with routing and versioning  
✅ **Multiple Lambda Functions**: Support for multiple endpoints  
✅ **CORS Support**: Pre-configured CORS for web applications  
✅ **Custom Domains**: Route53 integration with SSL/TLS  
✅ **API Keys & Usage Plans**: Rate limiting and quota management  
✅ **AWS X-Ray**: Distributed tracing enabled  
✅ **CloudWatch Logs**: Centralized logging for all functions  
✅ **VPC Integration**: Optional VPC access for Lambda  
✅ **Auto-Scaling**: Built-in concurrency management  

---

## 🏗️ Architecture

```
       Internet/Mobile Apps
              ↓
     [Route53 Custom Domain]
              ↓
       [API Gateway] ←→ [API Key + Usage Plan]
         /users  /orders
           ↓        ↓
       [Lambda]  [Lambda]
         ↓          ↓
      DynamoDB    RDS
         ↓
   [Secrets Manager]
```

---

## 🚀 Usage

### Basic REST API

```hcl
module "api" {
  source = "your-org/lambda-api-gateway/aws"
  version = "~> 1.0"

  aws_region   = "us-east-1"
  environment  = "production"
  project_name = "my-startup"

  api_name   = "my-api"
  stage_name = "v1"

  lambda_functions = {
    get_users = {
      handler          = "index.handler"
      runtime          = "nodejs20.x"
      filename         = "lambda/get-users.zip"
      source_code_hash = filebase64sha256("lambda/get-users.zip")
      memory_size      = 512
      timeout          = 30
      environment_variables = {
        TABLE_NAME = "users"
      }
      http_method   = "GET"
      http_path     = "/users"
      authorization = "NONE"
    }

    create_user = {
      handler          = "index.handler"
      runtime          = "nodejs20.x"
      filename         = "lambda/create-user.zip"
      source_code_hash = filebase64sha256("lambda/create-user.zip")
      memory_size      = 512
      timeout          = 30
      environment_variables = {
        TABLE_NAME = "users"
      }
      http_method   = "POST"
      http_path     = "/users"
      authorization = "AWS_IAM"
    }
  }

  enable_cors        = true
  cors_allow_origins = ["https://myapp.com"]
}
```

### With Custom Domain

```hcl
module "api_custom_domain" {
  source = "your-org/lambda-api-gateway/aws"
  version = "~> 1.0"

  aws_region   = "us-east-1"
  environment  = "production"
  project_name = "my-startup"

  api_name   = "my-api"
  stage_name = "v1"

  # Custom Domain
  enable_custom_domain = true
  custom_domain_name   = "api.myapp.com"
  certificate_arn      = "arn:aws:acm:us-east-1:123456789012:certificate/xxx"

  lambda_functions = {
    # ... function definitions
  }
}

# Create Route53 record
resource "aws_route53_record" "api" {
  zone_id = "Z1234567890ABC"
  name    = "api.myapp.com"
  type    = "A"

  alias {
    name                   = module.api_custom_domain.custom_domain_regional_domain_name
    zone_id                = module.api_custom_domain.custom_domain_regional_zone_id
    evaluate_target_health = false
  }
}
```

---

## 📥 Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| api_name | Name of the API | `string` | n/a | yes |
| environment | Environment name | `string` | n/a | yes |
| lambda_functions | Map of Lambda function configs | `map(object)` | n/a | yes |
| stage_name | API Gateway stage name | `string` | `"v1"` | no |
| enable_cors | Enable CORS | `bool` | `true` | no |
| cors_allow_origins | Allowed CORS origins | `list(string)` | `["*"]` | no |
| enable_custom_domain | Enable custom domain | `bool` | `false` | no |
| custom_domain_name | Custom domain name | `string` | `""` | no |
| certificate_arn | ACM certificate ARN | `string` | `""` | no |
| enable_api_key | Enable API key authentication | `bool` | `false` | no |
| enable_xray | Enable X-Ray tracing | `bool` | `true` | no |

---

## 📤 Outputs

| Name | Description |
|------|-------------|
| api_endpoint | API Gateway invoke URL |
| api_id | API Gateway ID |
| lambda_function_arns | ARNs of Lambda functions |
| custom_domain_name | Custom domain (if enabled) |
| api_key_value | API key value (sensitive) |

---

## 💰 Cost Estimation

### Lambda Pricing (us-east-1)
- **Requests**: $0.20 per 1M requests
- **Duration**: $0.0000166667 per GB-second
- **Free Tier**: 1M requests + 400,000 GB-seconds/month

### API Gateway Pricing
- **REST API**: $3.50 per million requests
- **Data Transfer**: $0.09/GB (first 10 TB)

### Example: Small API (1M requests/month, 512MB, 100ms average)
- Lambda Requests: 1M × $0.20/M = **$0.20**
- Lambda Duration: 1M × 0.1s × 0.5GB × $0.0000166667 = **$0.83**
- API Gateway: 1M × $3.50/M = **$3.50**
- **Total: ~$4.53/month**

### Example: Medium API (10M requests/month)
- Lambda: **~$10**
- API Gateway: **~$35**
- **Total: ~$45/month**

### Cost Optimization Tips
1. **Right-Size Memory**: Start with 512MB, optimize based on metrics
2. **Reduce Cold Starts**: Use Provisioned Concurrency for critical endpoints
3. **Batch Processing**: Process multiple items per invocation
4. **API Gateway Caching**: Enable caching for read-heavy endpoints
5. **HTTP API**: Consider HTTP API (cheaper than REST API)

---

## 🔒 Security Best Practices

### Built-In Security
✅ **IAM Least Privilege**: Separate execution roles per function  
✅ **Encryption**: Env vars encrypted with AWS KMS  
✅ **API Gateway Authorization**: Support for IAM, API Keys  
✅ **VPC Integration**: Optional private subnet deployment  
✅ **Secrets Management**: Integration with Secrets Manager  

### Recommendations

```hcl
# 1. Use IAM authorization for internal APIs
lambda_functions = {
  admin_function = {
    # ... other config
    authorization = "AWS_IAM"  # Require IAM credentials
  }
}

# 2. Enable API key for external APIs
enable_api_key = true

# 3. Store secrets securely
secrets = [
  {
    name      = "DB_PASSWORD"
    valueFrom = "arn:aws:secretsmanager:us-east-1:123456789012:secret:db-pass"
  }
]

# 4. Use VPC for database access
enable_vpc             = true
vpc_subnet_ids         = ["subnet-abc123"]
vpc_security_group_ids = ["sg-xyz789"]
```

---

## 📊 Monitoring

### CloudWatch Metrics
- **Invocations**: Function execution count
- **Duration**: Execution time
- **Errors**: Failed invocations
- **Throttles**: Concurrent execution limit hits
- **API 4XX/5XX**: Client/server errors

### X-Ray Tracing
Enable distributed tracing:
```hcl
enable_xray = true
```

View traces in AWS X-Ray console to analyze:
- End-to-end request flow
- Performance bottlenecks
- External service calls

---

## 🎯 Pro Version Features

**Upgrade to Pro tier ($499/month) for enterprise serverless:**

### 🎨 Advanced Monitoring
- **Lambda Insights**: Enhanced metrics and logs
- **Custom Dashboards**: API performance visualization
- **Cost Explorer Integration**: Per-function cost breakdown
- **Anomaly Detection**: ML-based alerting

### 🔐 Enhanced Security
- **WAF Integration**: Protect against common attacks
- **API Gateway Authorizers**: Custom JWT/OAuth validators
- **Secrets Rotation**: Automated secret rotation
- **VPC Endpoints**: Private API Gateway access

### ⚡ Performance Optimization
- **Provisioned Concurrency**: Eliminate cold starts
- **API Caching**: Redis-backed response caching
- **Lambda@Edge**: Global API distribution
- **Multi-Region**: Active-active deployment

### 💰 FinOps Automation
- **Cost Anomaly Detection**: Alert on unexpected charges
- **Right-Sizing**: ML-based memory recommendations
- **Reserved Capacity**: Savings plans guidance
- **Unused Function Detection**: Identify idle resources

### 🚀 CI/CD Integration
- **Canary Deployments**: Gradual traffic shifting
- **Automated Testing**: Integration test framework
- **Blue/Green Deployments**: Zero-downtime updates
- **GitHub Actions**: Pre-built deployment workflows

---

## 📚 Examples

See [examples/](examples/) directory

---

## 📄 License

MIT License - see [LICENSE](LICENSE)

---

**Built with ❤️ for serverless applications**

