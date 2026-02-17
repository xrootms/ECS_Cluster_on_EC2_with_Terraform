
output "ami_id" {
  value = data.aws_ami.amazon-linux-2.id
}


output "auto_scaling_group_arn" {
  value = aws_autoscaling_group.ctt_proj_dev_autoscaling_group.arn
}

output "auto_scaling_group_id" {
  value = aws_autoscaling_group.ctt_proj_dev_autoscaling_group.id
}