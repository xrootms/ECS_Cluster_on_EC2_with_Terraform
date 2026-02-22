# ECS_Cluster_on_EC2_with_Terraform

This project provisions a complete AWS infrastructure using Terraform to deploy a Node.js containerized application on Amazon ECS (EC2 launch type) behind an Application Load Balancer, with a custom domain and HTTPS enabled.
It follows Infrastructure as Code (IaC) best practices using modular Terraform design.

### Architecture Diagram

<p align="center">
  <img src="./doc/images/diagram.jpg" alt="LEMP Diagram" width="900">
</p>

### This setup provisions:

- ➡️ VPC (public & Private subnet, Nat gateway, EIP, Internet Gateway, and route tables)
- ➡️ Security Groups
- ➡️ VPC Endpoints
- ➡️ Bastion Host (EC2 in Public Subnet)
- ➡️ IAM Roles (ECS Instance Role, ECS Task Execution Role)
- ➡️ Auto Scaling Group (ECS Cluster Capacity)
- ➡️ ECS Cluster (EC2 launch type)
- ➡️ Application Load Balancer 
- ➡️ ACM SSL Certificate
- ➡️ Route 53 Hosted Zone & DNS Record

## Prerequisites
Before Running Terraform, Make sure you have the following prerequisites ready:

- ➡️ Terraform v1.3+ (recommended)
- ➡️ AWS CLI configured with proper IAM credentials
- ➡️ A registered domain name (e.g., from GoDaddy, Namecheap, etc.)
- ➡️ Hosted Zone created in Route 53 — Example: hosted zone name: api.techsaif.gzz.io
- ➡️ Name Servers updated at your domain registrar
- ➡️ Public and Private Key
- ➡️ Docker image pushed to Amazon ECR

## *Step 1:*  Setup ECR:

1️⃣ **Create an AWS ECR Repository**
 ```bash
  aws ecr create-repository --repository-name <Repo-name> --region ap-south-1
 ```
<p align="center">
  <img src="./doc/images/ecr-sample-node-app.png" alt="LEMP Diagram" width="700">
</p>

  *Save the given output URI.*
  
2️⃣ **Login Docker to ECR**
 ```bash
aws ecr get-login-password --region ap-south-1 | \
docker login --username AWS --password-stdin 471112623479.dkr.ecr.ap-south-1.amazonaws.com
 ```

3️⃣ **Build Docker Image Locally**
 ```bash
  docker build -t sample-node-app .
 ```
*Check Images:*
```bash
  docker images
 ```
  
4️⃣ **Tag the Image for ECR**
```bash
  docker tag sample-node-app:latest 471112623479.dkr.ecr.ap-south-1.amazonaws.com/sample-node-app:latest
```

5️⃣ **Push Image to ECR**
```bash
  docker push 471112623479.dkr.ecr.ap-south-1.amazonaws.com/sample-node-app:latest
```




## Infrastructure Evidence

All resources were provisioned via Terraform (no manual AWS Console creation).

Screenshots included for:

- Successful terraform apply
- Running ECS cluster
- Healthy ALB target group
- Issued ACM certificate
- Working HTTPS endpoint
