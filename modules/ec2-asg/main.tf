###############################
# Get latest Amazon Linux 2 A
###############################
data "aws_ami" "amazon-linux-2" {
  most_recent = true

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  owners = ["amazon"]
}


##################################
# Create Launch Template Resource
##################################
resource "aws_launch_template" "ctt_proj_dev_ecs_launch_template" {
  image_id               = data.aws_ami.amazon-linux-2.id
  instance_type          = var.ec2_asg_instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [var.sg_ec2_asg_id]
  update_default_version = true

  private_dns_name_options {
    enable_resource_name_dns_a_record = false
  }

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  monitoring {
    enabled = true
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 30
      volume_type = "gp2"
    }
  }

  #to apply tags to EC2 instances.
  tag_specifications {
    resource_type = "instance"

    tags = merge(var.common_tags, {
      Name = "${var.naming_prefix}-ECS-Instance"
    })
  }

  user_data = filebase64("${path.module}/ecs.sh")           # add cluster name inside ech.sh
}

###############################
# ASG-1Type: Auto Scaling Group (Scales EC2 container instances.)
# Create Auto Scaling group
###############################
resource "aws_autoscaling_group" "ctt_proj_dev_autoscaling_group" {
  name                  = var.ec2_asg_name
  vpc_zone_identifier   = tolist(var.private_subnets)
  desired_capacity      = 1                #2
  max_size              = 2                #6
  min_size              = 1
  health_check_type     = "EC2"                   # ASG checks only EC2 instance status
  protect_from_scale_in = false                     # true. NOT allowe to terminate this instance.

  #When you enable metrics, tells AWS to publish detailed ASG metrics to CloudWatch so you can monitor what’s happening inside the ASG.
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]

  launch_template {
    id      = aws_launch_template.ctt_proj_dev_ecs_launch_template.id
    version = aws_launch_template.ctt_proj_dev_ecs_launch_template.latest_version
  }

  #Enables rolling updates when the launch template changes and gradually replacing instances to ensure zero downtime
  instance_refresh {
    strategy = "Rolling"
  }

  #tag allows ECS to perform Scale the ASG up/down,Track instances correctly actions
  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}


