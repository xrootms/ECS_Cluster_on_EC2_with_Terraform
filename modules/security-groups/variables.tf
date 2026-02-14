variable "vpc_id" {}
variable "sg_ssh_http_https_ports" { default = [22, 80, 443] }
#variable "ec2_sg_name_for_python_api" {}

variable "common_tags" {}
variable "naming_prefix" {}


