# ECS Fargate Service Module - Production-Ready Serverless Container Deployment

terraform {
  required_version = ">= 1.5.0"
}

# Data source for current AWS account
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ========================================
# ECS Cluster
# ========================================

resource "aws_ecs_cluster" "main" {
  count = var.create_cluster ? 1 : 0

  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }

  tags = merge(
    var.tags,
    {
      Name        = var.cluster_name
      Environment = var.environment
    }
  )
}

# Use existing cluster if not creating new one
data "aws_ecs_cluster" "existing" {
  count = var.create_cluster ? 0 : 1

  cluster_name = var.cluster_name
}

locals {
  cluster_id   = var.create_cluster ? aws_ecs_cluster.main[0].id : data.aws_ecs_cluster.existing[0].id
  cluster_arn  = var.create_cluster ? aws_ecs_cluster.main[0].arn : data.aws_ecs_cluster.existing[0].arn
  cluster_name = var.cluster_name
  container_name = var.container_name != "" ? var.container_name : var.service_name
}

# ========================================
# Capacity Providers (Fargate + Fargate Spot)
# ========================================

resource "aws_ecs_cluster_capacity_providers" "main" {
  count = var.create_cluster && var.enable_fargate_spot ? 1 : 0

  cluster_name = local.cluster_name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 100 - var.fargate_spot_percentage
    base              = 1
  }

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = var.fargate_spot_percentage
  }

  depends_on = [aws_ecs_cluster.main]
}

# ========================================
# IAM Roles
# ========================================

# Task Execution Role (ECS Agent permissions)
resource "aws_iam_role" "execution" {
  count = var.execution_role_arn == "" ? 1 : 0

  name = "${var.service_name}-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name        = "${var.service_name}-execution-role"
      Environment = var.environment
    }
  )
}

resource "aws_iam_role_policy_attachment" "execution" {
  count = var.execution_role_arn == "" ? 1 : 0

  role       = aws_iam_role.execution[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Additional execution policy for Secrets Manager and SSM
resource "aws_iam_role_policy" "execution_secrets" {
  count = var.execution_role_arn == "" && length(var.secrets) > 0 ? 1 : 0

  name = "${var.service_name}-execution-secrets-policy"
  role = aws_iam_role.execution[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "ssm:GetParameters",
          "kms:Decrypt"
        ]
        Resource = "*"
      }
    ]
  })
}

# Task Role (Application permissions)
resource "aws_iam_role" "task" {
  count = var.task_role_arn == "" ? 1 : 0

  name = "${var.service_name}-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name        = "${var.service_name}-task-role"
      Environment = var.environment
    }
  )
}

# Policy for ECS Exec (debugging)
resource "aws_iam_role_policy" "task_exec" {
  count = var.enable_execute_command && var.task_role_arn == "" ? 1 : 0

  name = "${var.service_name}-exec-policy"
  role = aws_iam_role.task[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Resource = "*"
      }
    ]
  })
}

locals {
  execution_role_arn = var.execution_role_arn != "" ? var.execution_role_arn : aws_iam_role.execution[0].arn
  task_role_arn      = var.task_role_arn != "" ? var.task_role_arn : aws_iam_role.task[0].arn
}

# ========================================
# CloudWatch Log Group
# ========================================

resource "aws_cloudwatch_log_group" "main" {
  count = var.enable_logging ? 1 : 0

  name              = "/ecs/${var.cluster_name}/${var.service_name}"
  retention_in_days = var.log_retention_days

  tags = merge(
    var.tags,
    {
      Name        = "${var.service_name}-logs"
      Environment = var.environment
    }
  )
}

# ========================================
# Security Group for ECS Tasks
# ========================================

resource "aws_security_group" "ecs_tasks" {
  name_prefix = "${var.service_name}-ecs-tasks-"
  description = "Security group for ${var.service_name} ECS tasks"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name        = "${var.service_name}-ecs-tasks-sg"
      Environment = var.environment
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Allow ingress from ALB or other security groups
resource "aws_security_group_rule" "ecs_ingress_from_sg" {
  count = length(var.allowed_security_group_ids)

  type                     = "ingress"
  from_port                = var.container_port
  to_port                  = var.container_port
  protocol                 = "tcp"
  source_security_group_id = var.allowed_security_group_ids[count.index]
  security_group_id        = aws_security_group.ecs_tasks.id
  description              = "Allow traffic from ALB/other services"
}

# Allow ingress from CIDR blocks
resource "aws_security_group_rule" "ecs_ingress_from_cidr" {
  count = length(var.allowed_cidr_blocks) > 0 ? 1 : 0

  type              = "ingress"
  from_port         = var.container_port
  to_port           = var.container_port
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = aws_security_group.ecs_tasks.id
  description       = "Allow traffic from specified CIDR blocks"
}

# Allow all egress
resource "aws_security_group_rule" "ecs_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs_tasks.id
  description       = "Allow all outbound traffic"
}

# ========================================
# ECS Task Definition
# ========================================

resource "aws_ecs_task_definition" "main" {
  family                   = var.service_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = local.execution_role_arn
  task_role_arn            = local.task_role_arn

  container_definitions = jsonencode([
    {
      name      = local.container_name
      image     = var.container_image
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.host_port
          protocol      = "tcp"
        }
      ]

      environment = [
        for key, value in var.environment_variables : {
          name  = key
          value = value
        }
      ]

      secrets = var.secrets

      command    = var.command
      entryPoint = var.entrypoint

      logConfiguration = var.enable_logging ? {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.main[0].name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      } : null

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:${var.container_port}/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  tags = merge(
    var.tags,
    {
      Name        = "${var.service_name}-task-definition"
      Environment = var.environment
    }
  )
}

# ========================================
# ECS Service
# ========================================

resource "aws_ecs_service" "main" {
  name            = var.service_name
  cluster         = local.cluster_id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.desired_count
  launch_type     = var.enable_fargate_spot ? null : "FARGATE"

  platform_version = "LATEST"

  enable_execute_command = var.enable_execute_command

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = concat([aws_security_group.ecs_tasks.id], var.security_group_ids)
    assign_public_ip = false
  }

  dynamic "capacity_provider_strategy" {
    for_each = var.enable_fargate_spot ? [1] : []
    content {
      capacity_provider = "FARGATE"
      weight            = 100 - var.fargate_spot_percentage
      base              = 1
    }
  }

  dynamic "capacity_provider_strategy" {
    for_each = var.enable_fargate_spot ? [1] : []
    content {
      capacity_provider = "FARGATE_SPOT"
      weight            = var.fargate_spot_percentage
    }
  }

  dynamic "load_balancer" {
    for_each = var.enable_load_balancer ? [1] : []
    content {
      target_group_arn = var.target_group_arn
      container_name   = local.container_name
      container_port   = var.container_port
    }
  }

  health_check_grace_period_seconds = var.enable_load_balancer ? var.health_check_grace_period_seconds : null

  dynamic "service_registries" {
    for_each = var.enable_service_discovery ? [1] : []
    content {
      registry_arn = aws_service_discovery_service.main[0].arn
    }
  }

  deployment_configuration {
    maximum_percent         = 200
    minimum_healthy_percent = 100
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  tags = merge(
    var.tags,
    {
      Name        = var.service_name
      Environment = var.environment
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.execution
  ]
}

# ========================================
# Service Discovery (Optional)
# ========================================

resource "aws_service_discovery_service" "main" {
  count = var.enable_service_discovery ? 1 : 0

  name = var.service_name

  dns_config {
    namespace_id = var.service_discovery_namespace_id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.service_name}-discovery"
      Environment = var.environment
    }
  )
}

# ========================================
# Auto Scaling
# ========================================

resource "aws_appautoscaling_target" "ecs" {
  count = var.enable_autoscaling ? 1 : 0

  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${local.cluster_name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# CPU-based auto scaling
resource "aws_appautoscaling_policy" "ecs_cpu" {
  count = var.enable_autoscaling ? 1 : 0

  name               = "${var.service_name}-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = var.cpu_target_value
    scale_in_cooldown  = var.scale_in_cooldown
    scale_out_cooldown = var.scale_out_cooldown
  }
}

# Memory-based auto scaling
resource "aws_appautoscaling_policy" "ecs_memory" {
  count = var.enable_autoscaling ? 1 : 0

  name               = "${var.service_name}-memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value       = var.memory_target_value
    scale_in_cooldown  = var.scale_in_cooldown
    scale_out_cooldown = var.scale_out_cooldown
  }
}

