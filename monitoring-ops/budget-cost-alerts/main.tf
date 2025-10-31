resource "aws_budgets_budget" "monthly" {
  name              = "${var.environment}-monthly-budget"
  budget_type       = "COST"
  limit_amount      = var.monthly_budget_limit
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = formatdate("YYYY-MM-01_00:00", timestamp())

  dynamic "notification" {
    for_each = var.notification_thresholds
    content {
      comparison_operator        = "GREATER_THAN"
      threshold                  = notification.value
      threshold_type             = "PERCENTAGE"
      notification_type          = "ACTUAL"
      subscriber_email_addresses = var.email_addresses
    }
  }

  cost_filter {
    name   = "TagKeyValue"
    values = ["user:Environment$${var.environment}"]
  }
}

resource "aws_ce_anomaly_monitor" "main" {
  count             = var.enable_anomaly_detection ? 1 : 0
  name              = "${var.environment}-cost-anomaly-monitor"
  monitor_type      = "DIMENSIONAL"
  monitor_dimension = "SERVICE"
}

resource "aws_ce_anomaly_subscription" "main" {
  count     = var.enable_anomaly_detection ? 1 : 0
  name      = "${var.environment}-cost-anomaly-alerts"
  frequency = "DAILY"

  monitor_arn_list = [
    aws_ce_anomaly_monitor.main[0].arn
  ]

  subscriber {
    type    = "EMAIL"
    address = var.email_addresses[0]
  }

  threshold_expression {
    dimension {
      key           = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
      values        = [tostring(var.anomaly_threshold)]
      match_options = ["GREATER_THAN_OR_EQUAL"]
    }
  }
}

resource "aws_sns_topic" "cost_alerts" {
  name = "${var.environment}-cost-alerts"
  tags = merge(var.tags, {
    Name        = "${var.environment}-cost-alerts"
    Environment = var.environment
  })
}

resource "aws_sns_topic_subscription" "email" {
  count     = length(var.email_addresses)
  topic_arn = aws_sns_topic.cost_alerts.arn
  protocol  = "email"
  endpoint  = var.email_addresses[count.index]
}

