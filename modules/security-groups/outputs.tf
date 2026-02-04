output "sg_ec2_sg_ssh_http_https_id" {
  value = aws_security_group.ec2_sg_ssh_http_https.id
}

 output "sg_ec2_asg_id" {
   value = aws_security_group.sg_ec2_asg.id
 }

 output "sg_for_vpc_endpoints_https_id" {
   value = aws_security_group.sg_for_vpc_endpoints_https.id
 }


# output "rds_mysql_sg_id" {
#   value = aws_security_group.rds_mysql_sg.id
# }

# output "sg_ec2_for_python_api" {
#   value = aws_security_group.ec2_sg_python_api.id
# }



