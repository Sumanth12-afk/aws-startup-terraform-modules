module "cloudfront" {
  source = "../"

  environment        = "production"
  origin_domain_name = module.s3.bucket_regional_domain_name
  origin_type        = "s3"

  aliases             = ["www.example.com"]
  acm_certificate_arn = module.acm.certificate_arn

  tags = { Project = "MyApp" }
}

