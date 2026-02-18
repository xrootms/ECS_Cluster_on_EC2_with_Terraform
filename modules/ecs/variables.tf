
variable "aws_region" {}
variable "ecs_cluster_name" {}
variable "auto_scaling_group_arn" {}
variable "alb_target_group_arn" {}
variable "iam_role_ecsTaskExecutionRole_arn" {}


variable "container_name" {}
variable "image_uri" {}


variable "task_family_name" {}
variable "ecs_service_name" {}

variable "common_tags" {}
variable "naming_prefix" {}
