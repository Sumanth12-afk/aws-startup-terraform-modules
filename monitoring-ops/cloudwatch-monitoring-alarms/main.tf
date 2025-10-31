resource "aws_sns_topic" "alarms" {
  name = "${var.environment}-${var.alarm_topic_name}"
  tags = merge(var.tags, {
    Name        = "${var.environment}-${var.alarm_topic_name}"
    Environment = var.environment
  })
}

resource "aws_sns_topic_subscription" "email" {
  count     = length(var.email_endpoints)
  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = var.email_endpoints[count.index]
}

resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
  count               = var.enable_ec2_alarms ? length(var.ec2_instance_ids) : 0
  alarm_name          = "${var.environment}-ec2-${var.ec2_instance_ids[count.index]}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = var.ec2_cpu_threshold
  alarm_actions       = [aws_sns_topic.alarms.arn]

  dimensions = {
    InstanceId = var.ec2_instance_ids[count.index]
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  count               = var.enable_rds_alarms ? length(var.rds_instance_ids) : 0
  alarm_name          = "${var.environment}-rds-${var.rds_instance_ids[count.index]}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.rds_cpu_threshold
  alarm_actions       = [aws_sns_topic.alarms.arn]

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_ids[count.index]
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "alb_target_response_time" {
  count               = var.enable_alb_alarms ? length(var.alb_target_group_arns) : 0
  alarm_name          = "${var.environment}-alb-target-response-time-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Average"
  threshold           = var.alb_response_time_threshold
  alarm_actions       = [aws_sns_topic.alarms.arn]

  dimensions = {
    TargetGroup  = element(split(":", var.alb_target_group_arns[count.index]), 5)
    LoadBalancer = var.alb_names[count.index]
  }

  tags = var.tags
}

resource "aws_cloudwatch_dashboard" "main" {
  count          = var.create_dashboard ? 1 : 0
  dashboard_name = "${var.environment}-monitoring"

  dashboard_body = jsonencode({
    widgets = concat(
      var.enable_ec2_alarms ? [
        {
          type = "metric"
          properties = {
            metrics = [for id in var.ec2_instance_ids : ["AWS/EC2", "CPUUtilization", { "InstanceId" = id }]]
            period  = 300
            stat    = "Average"
            region  = var.aws_region
            title   = "EC2 CPU Utilization"
          }
        }
      ] : [],
      var.enable_rds_alarms ? [
        {
          type = "metric"
          properties = {
            metrics = [for id in var.rds_instance_ids : ["AWS/RDS", "CPUUtilization", { "DBInstanceIdentifier" = id }]]
            period  = 300
            stat    = "Average"
            region  = var.aws_region
            title   = "RDS CPU Utilization"
          }
        }
      ] : []
    )
  })
}

