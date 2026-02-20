# ECS_Cluster_on_EC2_with_Terraform

This project provisions a complete AWS infrastructure using Terraform to deploy a Node.js containerized application on Amazon ECS (EC2 launch type) behind an Application Load Balancer, with a custom domain and HTTPS enabled.
It follows Infrastructure as Code (IaC) best practices using modular Terraform design.

### ## Architecture Diagram

<p align="center">
  <img src="./doc/images/diagram.jpg" alt="LEMP Diagram" width="800">
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

## Prerequisites
Before Running Terraform, Make sure you have the following prerequisites ready:

- ➡️ Terraform v1.3+ (recommended)
- ➡️ AWS CLI configured with proper IAM credentials
- ➡️ A registered domain name (e.g., from GoDaddy, Namecheap, etc.)
- ➡️ Hosted Zone created in Route 53 — Example: hosted zone name: api.techsaif.gzz.io
- ➡️ Name Servers updated at your domain registrar
- ➡️ Public and Private Key
- ➡️ Docker image pushed to Amazon ECR



## Infrastructure Evidence

All resources were provisioned via Terraform (no manual AWS Console creation).

Screenshots included for:

- Successful terraform apply
- Running ECS cluster
- Healthy ALB target group
- Issued ACM certificate
- Working HTTPS endpoint
