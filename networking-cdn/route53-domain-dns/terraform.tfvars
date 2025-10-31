environment = "production"
domain_name = "example.com"

a_records = {
  "@" = {
    ttl     = 300
    records = ["192.0.2.1"]
  }
}

cname_records = {
  "www" = {
    ttl    = 300
    record = "example.com"
  }
}

alias_records = {
  "cdn" = {
    type                   = "A"
    target                 = "d111111abcdef8.cloudfront.net"
    zone_id                = "Z2FDTNDATAQYW2" # CloudFront hosted zone ID
    evaluate_target_health = false
  }
}

tags = {
  Project = "MyApp"
}

