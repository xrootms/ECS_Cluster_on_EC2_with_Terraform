####################################################
# create application load balancer
####################################################
resource "aws_lb" "ctt_proj_dev_alb" {
  name                       = var.lb_name
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [var.sg_enable_ssh_http_https]
  subnets                    = tolist(var.public_subnets)
  enable_deletion_protection = false

  tags = merge(var.common_tags, {
    Name = "${var.naming_prefix}-ALB"
  })
}
####################################################
# create target group for ALB
####################################################
resource "aws_lb_target_group" "ctt_proj_dev_lb_target_group" {
  name        = var.lb_target_group_name
  target_type = "instance"
  port        = 80     # ALB automatically forwards to correct dynamic port, ALB ignores the port = 80
  protocol    = "HTTP" # Tells ALB how to communicate with the targets
  vpc_id      = var.vpc_id

  health_check { # Health check = application reachability, not EC2 OS health
    healthy_threshold   = "2"
    unhealthy_threshold = "2"
    interval            = "60"
    path                = "/"                           # When the alb checks health, it does: GET http://<EC2-IP>:<dynamic-port>/
    timeout             = 30
    matcher             = 200
    #protocol            = "HTTP"       # Default, Tells ALB what protocol to use specifically for health checks (GET http://<EC2-IP>:<port>/)
    #port                = If omit port,ALB uses the port registered in the target group, dynamic port.
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.common_tags, {
    Name = "${var.naming_prefix}-ALB-TG"
  })
}

####################################################
# create a listener on port 80 with redirect action
# http listner on port 80
####################################################
# resource "aws_lb_listener" "ctt_proj_dev_proj_lb_http_listner" {
#   load_balancer_arn = aws_lb.ctt_proj_dev_alb.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.ctt_proj_dev_lb_target_group.arn

#   }
# }

# ==

# http listner on port 80
resource "aws_lb_listener" "ctt_proj_dev_proj_lb_http_listner" {
    load_balancer_arn = aws_lb.ctt_proj_dev_alb.arn
    port              = 80
    protocol          = "HTTP"

    default_action {
        type = "redirect"
        redirect {
            port        = "443"
            protocol    = "HTTPS"
            status_code = "HTTP_301"
        }
    }
}

# https listner on port 443
resource "aws_lb_listener" "ctt_proj_dev_lb_https_listner" {
    load_balancer_arn = aws_lb.ctt_proj_dev_alb.arn
    port              = 443
    protocol          = "HTTPS"
    ssl_policy        = "ELBSecurityPolicy-FS-1-2-Res-2019-08"
    certificate_arn   = var.ctt_proj_dev_acm_arn

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.ctt_proj_dev_lb_target_group.arn
    }
}