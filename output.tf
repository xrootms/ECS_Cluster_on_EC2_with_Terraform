output "ssh_connection_string_for_ec2-bastion" {
  value = "ssh -i ~/Documents/keys/devops_proj1 ubuntu@${module.ec2_bastion.bastion_ec2_instance_public_ip}"
}
output "alb_dns_name" {
  value = module.alb.alb_dns_name
}