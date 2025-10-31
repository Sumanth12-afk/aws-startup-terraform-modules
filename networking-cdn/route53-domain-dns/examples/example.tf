module "dns" {
  source = "../"

  environment = "production"
  domain_name = "example.com"

  alias_records = {
    "www" = {
      type                   = "A"
      target                 = module.cloudfront.domain_name
      zone_id                = module.cloudfront.hosted_zone_id
      evaluate_target_health = false
    }
  }

  tags = { Project = "MyApp" }
}

