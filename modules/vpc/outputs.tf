output "srl_proj_dev_vpc_id" {
  value = aws_vpc.srl_proj_dev_vpc.id
}

output "srl_proj_dev_public_subnets" {
  value = aws_subnet.srl_proj_dev_public_subnets.*.id
}

output "public_subnet_cidr_block" {
  value =aws_subnet.srl_proj_dev_public_subnets.*.cidr_block
}


output "srl_proj_dev_private_subnets" {
  value = aws_subnet.srl_proj_dev_private_subnets.*.id
}

output "private_subnet_cidr_block" {
  value =aws_subnet.srl_proj_dev_private_subnets.*.cidr_block
}