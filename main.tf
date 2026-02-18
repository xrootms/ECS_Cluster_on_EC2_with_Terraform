module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr             = var.vpc_cidr
  vpc_name             = var.vpc_name
  cidr_public_subnet   = var.cidr_public_subnet
  ap_availability_zone = var.ap_availability_zone
  cidr_private_subnet  = var.cidr_private_subnet
  common_tags          = local.common_tags
  naming_prefix        = local.naming_prefix
}

module "security_group" {
  source        = "./modules/security-groups"
  vpc_id        = module.vpc.ctt_proj_dev_vpc_id
  common_tags   = local.common_tags
  naming_prefix = local.naming_prefix
  #ec2_sg_name_for_python_api = "SG for EC2 for enabling port 5000"
}

module "vpc_endpoints" {
  source                     = "./modules/vpc-endpoints"
  aws_region                 = var.aws_region
  private_subnets            = module.vpc.ctt_proj_dev_private_subnets
  sg_for_vpc_endpoints_https = module.security_group.sg_for_vpc_endpoints_https_id
  vpc_id                     = module.vpc.ctt_proj_dev_vpc_id
  private_route_table_id     = module.vpc.private_route_table_id
  common_tags                = local.common_tags
  naming_prefix              = local.naming_prefix
}

module "ec2_bastion" {
  source                = "./modules/ec2-bastion"
  bastion_ami_id        = var.bastion_ec2_ami_id
  bastion_instance_type = "t2.micro"
  #iam_instance_profile     = module.iam_ec2_s3.instance_profile_name
  bastion_ec2_tag_name     = "Bastion"
  subnet_id                = tolist(module.vpc.ctt_proj_dev_public_subnets)[0]
  sg_for_bastion           = [module.security_group.sg_for_ssh_http_https_id]
  enable_public_ip_address = true
  user_data_install_app    = templatefile("./modules/template/ec2_install_apache.sh", {})
  key_name                 = aws_key_pair.main_key.key_name
  common_tags              = local.common_tags
  naming_prefix            = local.naming_prefix
  #depends_on               = [module.rds]
}

module "iam" {
  source                 = "./modules/iam"
  ecs_instance_role_name = "ecsInstanceRole"
  ecs_task_role_name     = "ecsTaskExecutionRole"
  common_tags            = local.common_tags
  naming_prefix          = local.naming_prefix
}


module "ec2_asg" {
  source                 = "./modules/ec2-asg"
  aws_region             = var.aws_region
  ec2_asg_instance_type  = "t3.medium"
  key_name               = aws_key_pair.main_key.key_name
  sg_ec2_asg_id          = module.security_group.sg_ec2_asg_id
  private_subnets        = module.vpc.ctt_proj_dev_private_subnets
  iam_instance_profile   = module.iam.instance_profile_ecsInstanceRoleProfile_name
  sg_vpc_endpoints       = module.security_group.sg_for_vpc_endpoints_https_id
  vpc_id                 = module.vpc.ctt_proj_dev_vpc_id
  private_route_table_id = module.vpc.private_route_table_id
  ec2_asg_name           = "CTT-PROJ-DEV-ASG"
  common_tags            = local.common_tags
  naming_prefix          = local.naming_prefix
}

module "ecs" {
  source                            = "./modules/ecs"
  aws_region                        = var.aws_region
  ecs_cluster_name                  = "CTT-PROJ-DEV-ECS-Cluster"
  auto_scaling_group_arn            = module.ec2_asg.auto_scaling_group_arn
  alb_target_group_arn              = module.alb.alb_target_group_arn
  iam_role_ecsTaskExecutionRole_arn = module.iam.iam_role_ecsTaskExecutionRole_arn
  task_family_name                  = "CTT-PROJ-DEV-ECS-Task"
  ecs_service_name                  = "CTT-PROJ-DEV-ECS-Service"
  container_name                    = "nodejs-app-container"
  image_uri                         = var.image_uri
  common_tags                       = local.common_tags
  naming_prefix                     = local.naming_prefix
}

####################################################
# Create load balancer with target group
####################################################

module "alb" {
  source                   = "./modules/alb"
  lb_name                  = "ctt-proj-dev-alb"
  sg_enable_ssh_http_https = module.security_group.sg_for_ssh_http_https_id
  public_subnets           = module.vpc.ctt_proj_dev_public_subnets
  lb_target_group_name     = "CTT-PROJ-DEV-LB-Target-Group"
  vpc_id                   = module.vpc.ctt_proj_dev_vpc_id
  ctt_proj_dev_acm_arn     = module.aws_ceritification_manager.ctt_proj_dev_acm_arn
  common_tags              = local.common_tags
  naming_prefix            = local.naming_prefix
}


module "hosted_zone" {
  source          = "./modules/hosted-zone"
  domain_name     = var.domain_name
  aws_lb_dns_name = module.alb.alb_dns_name
  aws_lb_zone_id  = module.alb.aws_lb_zone_id
}


module "aws_ceritification_manager" {
  source         = "./modules/certificate-manager"
  domain_name    = var.domain_name
  hosted_zone_id = module.hosted_zone.hosted_zone_id
  common_tags              = local.common_tags
  naming_prefix            = local.naming_prefix
}

