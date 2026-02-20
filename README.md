# ECS_Cluster_on_EC2_with_Terraform

This project provisions a complete AWS infrastructure using Terraform to deploy a Node.js containerized application on Amazon ECS (EC2 launch type) behind an Application Load Balancer, with a custom domain and HTTPS enabled.
It follows Infrastructure as Code (IaC) best practices using modular Terraform design.

### Architecture Overview

### Diagram

<p align="center">
  <img src="./doc/image/diagram.jpg" alt="LEMP Diagram" width="800">
</p>

### This setup provisions:

- VPC
- Security Groups
- VPC Endpoints
- Bastion Host (EC2 in Public Subnet)
- IAM Roles (ECS Instance Role, ECS Task Execution Role)
- Auto Scaling Group (ECS Cluster Capacity)
- ECS Cluster (EC2 launch type)
- Application Load Balancer 
- ACM SSL Certificate
- Route 53 Hosted Zone & DNS Record



## Infrastructure Evidence

All resources were provisioned via Terraform (no manual AWS Console creation).

Screenshots included for:

- Successful terraform apply
- Running ECS cluster
- Healthy ALB target group
- Issued ACM certificate
- Working HTTPS endpoint
