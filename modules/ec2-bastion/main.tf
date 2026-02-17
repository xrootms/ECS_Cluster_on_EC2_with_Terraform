



resource "aws_instance" "ctt_proj_dev_ec2_bastion" {
  ami           = var.bastion_ami_id
  instance_type = var.bastion_instance_type
  #  iam_instance_profile   = var.iam_instance_profile

  tags = merge(var.common_tags, {
    Name = "${var.naming_prefix}-EC2-${var.bastion_ec2_tag_name}"
  })



  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.sg_for_bastion
  associate_public_ip_address = var.enable_public_ip_address
  user_data                   = var.user_data_install_app

  metadata_options {
    http_endpoint = "enabled"  # Enable the IMDSv2 endpoint
    http_tokens   = "required" # Require the use of IMDSv2 tokens
  }
}