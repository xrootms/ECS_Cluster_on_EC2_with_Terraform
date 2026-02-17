output "alb_dns_name" {
  value = aws_lb.ctt_proj_dev_alb.dns_name
}

output "aws_lb_zone_id" {
  value = aws_lb.ctt_proj_dev_alb.zone_id
}

output "alb_target_group_arn" {
  value = aws_lb_target_group.ctt_proj_dev_lb_target_group.arn
}