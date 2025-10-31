resource "aws_route53_zone" "main" {
  name    = var.domain_name
  comment = "${var.environment} hosted zone for ${var.domain_name}"

  tags = merge(var.tags, {
    Name        = var.domain_name
    Environment = var.environment
  })
}

resource "aws_route53_record" "a_records" {
  for_each = var.a_records

  zone_id = aws_route53_zone.main.zone_id
  name    = each.key
  type    = "A"
  ttl     = each.value.ttl
  records = each.value.records
}

resource "aws_route53_record" "cname_records" {
  for_each = var.cname_records

  zone_id = aws_route53_zone.main.zone_id
  name    = each.key
  type    = "CNAME"
  ttl     = each.value.ttl
  records = [each.value.record]
}

resource "aws_route53_record" "mx_records" {
  count   = length(var.mx_records) > 0 ? 1 : 0
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "MX"
  ttl     = 3600
  records = var.mx_records
}

resource "aws_route53_record" "txt_records" {
  for_each = var.txt_records

  zone_id = aws_route53_zone.main.zone_id
  name    = each.key
  type    = "TXT"
  ttl     = each.value.ttl
  records = each.value.records
}

resource "aws_route53_record" "alias_records" {
  for_each = var.alias_records

  zone_id = aws_route53_zone.main.zone_id
  name    = each.key
  type    = each.value.type

  alias {
    name                   = each.value.target
    zone_id                = each.value.zone_id
    evaluate_target_health = each.value.evaluate_target_health
  }
}

resource "aws_route53_health_check" "main" {
  for_each = var.health_checks

  fqdn              = each.value.fqdn
  port              = each.value.port
  type              = each.value.type
  resource_path     = each.value.resource_path
  failure_threshold = each.value.failure_threshold
  request_interval  = each.value.request_interval

  tags = merge(var.tags, {
    Name = "${each.key}-health-check"
  })
}

