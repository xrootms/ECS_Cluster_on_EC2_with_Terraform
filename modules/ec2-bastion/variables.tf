variable "bastion_ami_id" {}
variable "bastion_instance_type" {}
#variable "iam_instance_profile" {}
variable "bastion_ec2_tag_name" {}
variable "key_name" {}
variable "subnet_id" {}
variable "sg_for_bastion" {}
variable "enable_public_ip_address" {}
variable "user_data_install_app" {}

variable "common_tags" {}
variable "naming_prefix" {}