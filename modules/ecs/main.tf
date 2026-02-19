####################################################
# Create cloudWatch Log Group to Stores container logs
####################################################
resource "aws_cloudwatch_log_group" "log" {
  name              = "/${var.ecs_cluster_name}/${var.container_name}"
  retention_in_days = 14
}

########################
# Create an ECS cluster
#########################
resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.ecs_cluster_name

  tags = merge(var.common_tags, {
    Name = "${var.naming_prefix}-ecs-cluster"
  })
}

####################################################
# ASG-2Type:-ECS Capacity provider Auto Scaling (Coordinates ECS task scaling with EC2 scaling.)
# Create an ECS capacity Provider 
####################################################
resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
  name = "capacity_provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = var.auto_scaling_group_arn
    managed_termination_protection = "ENABLED"              # "ENABLED" : Prevents ECS from terminating EC2 instances that are still running tasks.

    managed_scaling {                                       # ECS scales based on: Task demand
      maximum_scaling_step_size = 5                         # Adds max 5 EC2 at once
      minimum_scaling_step_size = 1
      status                    = "ENABLED"                 # Don’t terminate instances that still have tasks
      target_capacity           = 100                       # It will add instances only when there’s no room for new tasks (ECS-on-EC2 setups use 100.)
    }
  }
}

####################################################################################
# Create an ECS Cluster capacity Provider: (Attaches capacity providers to an ECS cluster.)
####################################################################################
resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_capacity_provider" {
  cluster_name       = aws_ecs_cluster.ecs_cluster.name
  capacity_providers = [aws_ecs_capacity_provider.ecs_capacity_provider.name]
}

################################
# Create an ECS Task Definition
################################
resource "aws_ecs_task_definition" "ecs_task_definition" {
  family             = var.task_family_name                                  # becomes the task definition family name
  network_mode       = "bridge"
  execution_role_arn = var.iam_role_ecsTaskExecutionRole_arn

  runtime_platform {
    operating_system_family = "LINUX"                                        # Only place this task on Linux, x86_64 hosts.
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name      = var.container_name                                    # container name
      image     = var.image_uri                                         # "197317184204.dkr.ecr.us-east-1.amazonaws.com/simple-nodejs-app"
      cpu       = 200                                                   # values to: Decide task placementand Trigger EC2 scaling via capacity providers
      memory    = 200
      essential = true                                                  # If container stops or crashes, ECS marks the task as failed and starts a new task with a new task ID.
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 0
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"                                             # awslogs comes preinstalled via the ECS-optimized AMI and works automatically
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.log.name
          "awslogs-region"        = var.aws_region                        # ECS can send logs only to a log group in the same region
          "awslogs-stream-prefix" = var.container_name                    # ECS automatically creates one log stream per task
        }
      }
    }
  ])
}


####################################################
# Define the ECS service that will run the task
# Always keep my app running.
####################################################
resource "aws_ecs_service" "ecs_service" {
  name                               = var.ecs_service_name
  cluster                            = aws_ecs_cluster.ecs_cluster.id
  task_definition                    = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count                      = 4                                            # Always try to keep 4 tasks RUNNING
  deployment_minimum_healthy_percent = 50                                           # During deployment: Minimum running tasks: 50% of 4 = 2
  deployment_maximum_percent         = 100                                          # ECS will not exceed 100% of desired_count while deploying.

  #force_delete                      = true                                         # line for Dev ENV

  
  ordered_placement_strategy {
    type  = "spread"                                                                # Spread tasks evenly accross all Availability Zones for High Availability
    field = "attribute:ecs.availability-zone"
  }

  ## Make use of all available space on the Container Instances
  ordered_placement_strategy {
    type  = "binpack"
    field = "memory"
  }

  triggers = {
    redeployment = timestamp()                                                  # Every terraform apply forces a new deployment
  }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name    # Ensures ECS uses the right capacity provider
    weight            = 100                                                     # e.g., 70% FARGATE, 30% FARGATE_SPOT
  }

  load_balancer {                                                               #tg attachment: attach tg to ECS service not to ASG
    target_group_arn = var.alb_target_group_arn                                 # Registers each task with the ALB target group
    container_name   = var.container_name                                       # must match task definition container_name
    container_port   = 8080                                                     # Routes traffic to container port 8080
  }
}


###################################################################
# ASG-3Type: ECS service Auto Scaling (Scales ECS tasks, (not EC2 instances).
# Define the ECS service auto scaling
###################################################################
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 25                                                                                # ECS can scale up to 50 tasks max.ex-50
  min_capacity       = 2                                                                                 # ECS will always keep at least 2 tasks running
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.ecs_service.name}" # Points to a specific ECS service inside a specific ECS cluster
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  name               = "${var.naming_prefix}-memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {                                           # No alarms needed, Automatically balances scale-in/out
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value = 80                                                                      # Above 80% → add tasks, Below 80% → remove tasks (slowly)
  }
}

resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "${var.naming_prefix}-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 80
  }
}