#----SG for ports: 22, 80, 443----
resource "aws_security_group" "sg_ssh_http_https" {
  name        = "SG for ec2-Bastion & ALB to enable 22, 80 and HTTPS"
  vpc_id      = var.vpc_id
  description = "Enable the Port 22, 80, 443"

  #Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outgoing request to anywhere"
  }

  tags = merge(var.common_tags, {
    Name = "Security Group: SSH, HTTP, HTTPS"
  })
}

#Ingress rules using count
resource "aws_security_group_rule" "sg_ingress_ssh_http_https" {
  count             = length(var.sg_ssh_http_https_ports)
  type              = "ingress"
  from_port         = var.sg_ssh_http_https_ports[count.index]
  to_port           = var.sg_ssh_http_https_ports[count.index]
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_ssh_http_https.id
  description       = "Allow port ${var.sg_ssh_http_https_ports[count.index]} from anywhere"
}


##############################
# Security Group for ec2_asg
##############################
resource "aws_security_group" "sg_ec2_asg" {
  name        = "SG for EC2-ASG to enable port 1024-65535, 22"
  description = "Allow traffic for EC2"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow ingress traffic from ALB on HTTP on ephemeral ports"
    from_port       = 1024
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_ssh_http_https.id]          #Only traffic coming from alb that have SG attached can reach ec2-asg on port 1024-65535.
  }

  ingress {
    description     = "Allow SSH ingress traffic from bastion host"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_ssh_http_https.id]          #Only traffic coming from bastion-ec2 that have SG attached can reach ec2-asg on port 22.
  }

  egress {
    description = "Allow all egress traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "Security Group: 1024-65535, 22"
  })
}


##############################################
# Create the security group for VPC Endpoints
##############################################

resource "aws_security_group" "sg_for_vpc_endpoints_https" {
  name        = "SG for vpc endpoints to allow 443"
  description = "Allow traffic for VPC Endpoints"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow ingress traffic from EC2 Hosts"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_ec2_asg.id]         #Only resources that belong to "sg-ec2-asg" can reach the endpoint.
  }

  egress {
    description = "Allow all egress traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "Security Group: vpc-endpoints"
  })
}

/*
###########################
# # Security Group for app
###########################
# resource "aws_security_group" "ec2_sg_python_api" {
#   name        = var.ec2_sg_name_for_python_api
#   vpc_id      = var.vpc_id
#   description = "Enable the Port 5000 for python api"

#   ingress {
#     from_port   = 5000
#     to_port     = 5000
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#     description = "Allow traffic on port 5000"
#   }
#   tags = { Name = "Security Group: 5000" }
# }

###########################
# # Security Group for RDS
###########################
# resource "aws_security_group" "rds_mysql_sg" {
#   name        = "SG for RDS to enable port 3306"
#   vpc_id      = var.vpc_id
#   description = "Allow access to RDS from EC2 present in public subnet"

#   ingress {
#     from_port       = 3306
#     to_port         = 3306
#     protocol        = "tcp"
#     security_groups = [aws_security_group.ec2_sg_python_api.id] #Only traffic coming from EC2 instances that have SG-Python-API attached can reach DB on port 3306.
#     description     = "Allow MySQL from EC2 SG"
#   }
#   tags = { Name = "Security Group: 3360" }
# }*/