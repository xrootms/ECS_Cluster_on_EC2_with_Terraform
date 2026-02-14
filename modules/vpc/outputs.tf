output "ctt_proj_dev_vpc_id" {
  value = aws_vpc.ctt_proj_dev_vpc.id
}

output "ctt_proj_dev_public_subnets" {
  value = aws_subnet.ctt_proj_dev_public_subnets.*.id
}

output "public_subnet_cidr_block" {
  value =aws_subnet.ctt_proj_dev_public_subnets.*.cidr_block
}


output "ctt_proj_dev_private_subnets" {
  value = aws_subnet.ctt_proj_dev_private_subnets.*.id
}

output "private_subnet_cidr_block" {
  value =aws_subnet.ctt_proj_dev_private_subnets.*.cidr_block
}


output "private_route_table_id" {
  value = aws_route_table.ctt_proj_dev_private_route_table.id
}
