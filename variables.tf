variable "vpc_cidr" {
  type        = string
  description = "CIDR values"
}

variable "vpc_name" {
  type        = string
  description = "Project 1 VPC 1"
}

variable "cidr_public_subnet" {
  type        = list(string)
  description = "Public Subnet CIDR values"
}
variable "ap_availability_zone" {
  type        = list(string)
  description = "Availability Zones"
}

variable "cidr_private_subnet" {
  type        = list(string)
  description = "Private Subnet CIDR values"
}


variable "bastion_ec2_ami_id" {
  type        = string
  description = "AMI Id for EC2 instance"
}

variable "aws_region" {
  type        = string
  description = "AWS region to use for resources."
}

variable "naming_prefix" {
  type        = string
  description = "Naming prefix for all resources."
  default     = "CTT-PROJ-DEV"
}

variable "environment" {
  type        = string
  description = "Environment for deployment"
  default     = "DEV"
}


variable "company" {
  type        = string
  description = "Company name for resource tagging"
  default     = "MS"
}

variable "project" {
  type        = string
  description = "Project name for resource tagging"
  default     = "CTT"
}


variable "image_uri" {
  type        = string
  description = "image uri"
}

variable "domain_name" {
  type = string
  description = "Name of the domain"
}