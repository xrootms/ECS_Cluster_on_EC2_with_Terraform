output "sg_ec2_sg_ssh_http_id" {
  value = aws_security_group.ec2_sg_ssh_http.id
}

# output "rds_mysql_sg_id" {
#   value = aws_security_group.rds_mysql_sg.id
# }

# output "sg_ec2_for_python_api" {
#   value = aws_security_group.ec2_sg_python_api.id
# }


 output "security_group_ec2_id" {
   value = aws_security_group.security_group_ec2.id
 }

 output "sg_vpc_endpoints_id" {
   value = aws_security_group.sg_vpc_endpoints.id
 }




