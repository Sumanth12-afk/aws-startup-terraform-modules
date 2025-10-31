environment        = "production"
origin_domain_name = "my-bucket.s3.amazonaws.com"
origin_type        = "s3"

aliases             = ["www.example.com"]
# acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/abc123"

price_class         = "PriceClass_100"
enable_compression  = true

tags = {
  Project = "MyApp"
}

