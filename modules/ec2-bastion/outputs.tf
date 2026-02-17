output "bastion_ec2_instance_id" {
  value = aws_instance.ctt_proj_dev_ec2_bastion.id
}

output "bastion_ec2_instance_public_ip" {
  value = aws_instance.ctt_proj_dev_ec2_bastion.public_ip
}