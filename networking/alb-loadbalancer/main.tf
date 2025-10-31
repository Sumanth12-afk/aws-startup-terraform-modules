# Application Load Balancer Module - Production-Ready ALB with SSL/TLS

terraform {
  required_version = ">= 1.5.0"
}

# Security Group for ALB
resource "aws_security_group" "alb" {
  name_prefix = "${var.name}-alb-sg-"
  description = "Security group for ${var.name} Application Load Balancer"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name        = "${var.name}-alb-sg"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ALB Security Group Rules - HTTP
resource "aws_security_group_rule" "alb_http_ingress" {
  count = var.enable_http ? 1 : 0

  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = aws_security_group.alb.id
  description       = "Allow HTTP traffic from internet"
}

# ALB Security Group Rules - HTTPS
resource "aws_security_group_rule" "alb_https_ingress" {
  count = var.enable_https ? 1 : 0

  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = aws_security_group.alb.id
  description       = "Allow HTTPS traffic from internet"
}

# ALB Security Group Rules - Egress
resource "aws_security_group_rule" "alb_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
  description       = "Allow all outbound traffic"
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = concat([aws_security_group.alb.id], var.additional_security_groups)
  subnets            = var.subnet_ids

  enable_deletion_protection       = var.enable_deletion_protection
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  enable_http2                     = var.enable_http2
  enable_waf_fail_open             = var.enable_waf_fail_open
  drop_invalid_header_fields       = var.drop_invalid_header_fields
  idle_timeout                     = var.idle_timeout

  dynamic "access_logs" {
    for_each = var.enable_access_logs ? [1] : []
    content {
      bucket  = var.access_logs_bucket
      prefix  = var.access_logs_prefix
      enabled = true
    }
  }

  tags = merge(
    var.tags,
    {
      Name        = var.name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# Target Group for HTTP/HTTPS
resource "aws_lb_target_group" "main" {
  for_each = var.target_groups

  name        = "${var.name}-${each.key}"
  port        = each.value.port
  protocol    = each.value.protocol
  vpc_id      = var.vpc_id
  target_type = each.value.target_type

  deregistration_delay = each.value.deregistration_delay

  health_check {
    enabled             = true
    healthy_threshold   = each.value.health_check.healthy_threshold
    unhealthy_threshold = each.value.health_check.unhealthy_threshold
    timeout             = each.value.health_check.timeout
    interval            = each.value.health_check.interval
    path                = each.value.health_check.path
    port                = each.value.health_check.port
    protocol            = each.value.health_check.protocol
    matcher             = each.value.health_check.matcher
  }

  dynamic "stickiness" {
    for_each = each.value.stickiness_enabled ? [1] : []
    content {
      type            = "lb_cookie"
      enabled         = true
      cookie_duration = each.value.stickiness_duration
    }
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.name}-${each.key}"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# HTTP Listener (with redirect to HTTPS)
resource "aws_lb_listener" "http" {
  count = var.enable_http ? 1 : 0

  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = var.enable_https && var.http_redirect_to_https ? "redirect" : "forward"

    dynamic "redirect" {
      for_each = var.enable_https && var.http_redirect_to_https ? [1] : []
      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    target_group_arn = var.enable_https && var.http_redirect_to_https ? null : aws_lb_target_group.main[var.default_target_group].arn
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.name}-http-listener"
      Environment = var.environment
    }
  )
}

# HTTPS Listener
resource "aws_lb_listener" "https" {
  count = var.enable_https ? 1 : 0

  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[var.default_target_group].arn
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.name}-https-listener"
      Environment = var.environment
    }
  )
}

# Additional SSL Certificates
resource "aws_lb_listener_certificate" "additional" {
  count = var.enable_https ? length(var.additional_certificates) : 0

  listener_arn    = aws_lb_listener.https[0].arn
  certificate_arn = var.additional_certificates[count.index]
}

# Path-Based Routing Rules
resource "aws_lb_listener_rule" "path_based" {
  for_each = var.listener_rules

  listener_arn = var.enable_https ? aws_lb_listener.https[0].arn : aws_lb_listener.http[0].arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[each.value.target_group].arn
  }

  dynamic "condition" {
    for_each = each.value.path_patterns != null ? [1] : []
    content {
      path_pattern {
        values = each.value.path_patterns
      }
    }
  }

  dynamic "condition" {
    for_each = each.value.host_headers != null ? [1] : []
    content {
      host_header {
        values = each.value.host_headers
      }
    }
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.name}-${each.key}"
      Environment = var.environment
    }
  )
}

# CloudWatch Alarms for ALB
resource "aws_cloudwatch_metric_alarm" "target_response_time" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${var.name}-high-response-time"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Average"
  threshold           = var.target_response_time_threshold
  alarm_description   = "This metric monitors ALB target response time"
  alarm_actions       = var.alarm_actions

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.name}-response-time-alarm"
      Environment = var.environment
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${var.name}-unhealthy-hosts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Average"
  threshold           = var.unhealthy_host_threshold
  alarm_description   = "This metric monitors unhealthy host count"
  alarm_actions       = var.alarm_actions

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
    TargetGroup  = aws_lb_target_group.main[var.default_target_group].arn_suffix
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.name}-unhealthy-hosts-alarm"
      Environment = var.environment
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "elb_5xx_errors" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${var.name}-high-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = var.elb_5xx_threshold
  alarm_description   = "This metric monitors ALB 5XX errors"
  alarm_actions       = var.alarm_actions

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.name}-5xx-errors-alarm"
      Environment = var.environment
    }
  )
}

