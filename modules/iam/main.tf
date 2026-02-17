####################################################
#Create an IAM role - ecsInstanceRole  
####################################################

#1.Fetches an existing AWS-managed policy
data "aws_iam_policy" "ecsInstanceRolePolicy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}
#2.Creates a trust policy (Who is allowed to use (assume) this role?)
data "aws_iam_policy_document" "ecsInstanceRolePolicy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

#3.Creates an IAM role for EC2
resource "aws_iam_role" "ecsInstanceRole" {
  name               = var.ecs_instance_role_name
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecsInstanceRolePolicy.json

  tags = merge(var.common_tags, {
    Name = "${var.naming_prefix}-ecsInstanceRole"
  })
}

#4. Attaches the ECS policy to the role
resource "aws_iam_role_policy_attachment" "ecsInstancePolicy" {
  role       = aws_iam_role.ecsInstanceRole.name
  policy_arn = data.aws_iam_policy.ecsInstanceRolePolicy.arn
}

#5.Creates an instance profile (so EC2 can use it)
resource "aws_iam_instance_profile" "ecsInstanceRoleProfile" {
  name = aws_iam_role.ecsInstanceRole.name
  role = aws_iam_role.ecsInstanceRole.name
}




######################################################
# Create an IAM role - ecsTaskExecutionRole  
####################################################

# Policy that allows ECS tasks to: Pull images from ECR, Write logs to CloudWatch
data "aws_iam_policy" "ecsTaskExecutionRolePolicy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# This allows ECS tasks (not users, not EC2) to assume the role.
data "aws_iam_policy_document" "ecsExecutionRolePolicy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

#Creates the IAM role
resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = var.ecs_task_role_name
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecsExecutionRolePolicy.json

  tags = merge(var.common_tags, {
    Name = "${var.naming_prefix}-ecsTaskExecutionRole"
  })
}

#Attaches the execution policy
resource "aws_iam_role_policy_attachment" "ecsTaskExecutionPolicy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = data.aws_iam_policy.ecsTaskExecutionRolePolicy.arn
}
