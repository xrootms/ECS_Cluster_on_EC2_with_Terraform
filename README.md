# ECS Cluster on EC2 with Terraform
This project implements a production-ready container platform on AWS using Terraform as Infrastructure as Code (IaC).

It provisions a secure, scalable, and highly available environment to run a containerized Node.js application on Amazon Elastic Container Service (EC2 launch type) behind an Application Load Balancer, with a custom domain and HTTPS enforced via AWS Certificate Manager.


### Architecture Diagram

<p align="center">
  <img src="./doc/images/diagram.jpg" alt="LEMP Diagram" width="900">
</p>

### This setup provisions:
- VPC *(public & Private subnet, Nat, EIP, Internet Gateway, and route tables)*
- Security Groups
- VPC Endpoints
- Bastion Host *(EC2 in Public Subnet)*
- IAM Roles *(ECS Instance Role, ECS Task Execution Role)*
- Auto Scaling Group *(ECS Cluster Capacity)*
- ECS Cluster *(EC2 launch type)*
- Application Load Balancer 
- ACM SSL Certificate
- Route 53 Hosted Zone & DNS Record
  
### Security Design
- ECS instances are in Private Subnets
- Only ALB is publicly accessible
- Bastion Host for SSH access
- Security Groups follow least privilege principle
- VPC Endpoints enable private access to AWS services (ex. S3, ECR) without traversing the public internet.
- NAT Gateway provides secure outbound internet access (ex. OS updates) while preventing inbound exposure.
- IAM roles are scoped with minimum required permissions.
- HTTPS enforced with ACM certificate

### High Availability & Scalability
- Multi-AZ subnet distribution
- Auto Scaling Group backing ECS capacity
- Elastic load balancing across availability zones
- Decoupled networking and compute layers

## Prerequisites
Before Running Terraform, Make sure you have the following prerequisites ready:

- Terraform v1.3+ *(recommended)*
- AWS CLI configured with proper IAM credentials
- A registered domain name *(e.g., from GoDaddy, Namecheap, etc.)*
- Hosted Zone created in Route 53 — Example: hosted zone name: api.techsaif.gzz.io
- Name Servers updated at your domain registrar
- Public and Private Key
- Docker image pushed to Amazon ECR

## Step 1️⃣: 
### Setup ECR:

1️. **Create an AWS ECR Repository and Save the given output URI.**
 ```bash
  aws ecr create-repository --repository-name sample-node-app --region ap-south-1
 ```

<p align="center">
  <img src="./doc/images/ecr-sample-node-app.png" alt="LEMP Diagram" width="900">
</p>
  
2️. **Login Docker to ECR**
 ```bash
aws ecr get-login-password --region ap-south-1 | \
docker login --username AWS --password-stdin 471112623479.dkr.ecr.ap-south-1.amazonaws.com
 ```

3️. **Build Docker Image Locally**
 ```bash
  docker build -t sample-node-app .

  docker images    #Check Images
 ```
  
4️. **Tag the Image for ECR**
```bash
  docker tag sample-node-app:latest 471112623479.dkr.ecr.ap-south-1.amazonaws.com/sample-node-app:latest
```

5️. **Push Image to ECR**
```bash
  docker push 471112623479.dkr.ecr.ap-south-1.amazonaws.com/sample-node-app:latest
```

## Step 2️⃣:
### Setup Hosted Zone :
To work with this whole setup we need to setup  Route53 and in Route53 we first need to setup our hosted zone.

1️.  Navigate to Route 53 → Hosted zones → Create hosted zone

2️.  In the Domain name field, enter the exact domain name you own (e.g., techsaif.gzz.io)

3️.  Select Type → Public hosted zone

4️.  Click Create hosted zone

5️. Once you created you will get these four records which is "ns records".

6️. Update these ns recode over your domine register's ns recode.

<p align="center">
  <img src="./doc/images/domain-ns.png" alt="LEMP Diagram" width="600">
</p>

## Step 3️⃣:
####  Clone the repo:
   ```bash
   git clone https://github.com/xrootms/ECS_Cluster_on_EC2_with_Terraform.git
   cd ECS_Cluster_on_EC2_with_Terraform
   ```

#### 2. Copy and edit variables: (Update variable values as needed — VPC, CIDR, public key, region, etc.)
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

#### 3. Initialize Terraform:
   ```bash
   terraform init
   ```

#### 4. Plan and Apply:
   ```bash
   terraform plan
   terraform apply
   ```

#### 5. Get ssh connection for Bastion EC2:

---
## *After successful deployment:*

🔹**Hosted zone:**

  - *The ALB DNS name is mapped to **www.api.techsaif.gzz.io** and **api.techsaif.gzz.io** using a Route 53 A record*

<p align="center">
  <img src="./doc/images/Route53-hz.png" alt="LEMP Diagram" width="900">
</p>

🔹**SSL Configuration:**

  - *An ACM Certificate is created for: **www.api.techsaif.gzz.io & api.techsaif.gzz.io** and attached to the ALB for https traffic.*

<p align="center">
  <img src="./doc/images/acm.png" alt="LEMP Diagram" width="900">
</p>

🔹**Accessing Node app:**

  - *Once Terraform apply completes and DNS propagation finishes:*
  - *Open https://api.techsaif.gzz.io in your browser.*

<p align="center">
  <img src="./doc/images/browser.png" alt="LEMP Diagram" width="900">
</p>

🔹**ECS Cluster running - Tasks:**
<p align="center">
  <img src="./doc/images/ECS-Cluster.png" alt="LEMP Diagram" width="900">
</p>

🔹**ECS Cluster - Services:**

<p align="center">
  <img src="./doc/images/ECS-Cluster-Servics.png" alt="LEMP Diagram" width="900">
</p>

🔹**ECS Cluster - Infrastructure:**

<p align="center">
  <img src="./doc/images/ECS-Cluster-Servics-Infrastructure2.png" alt="LEMP Diagram" width="900">
</p>

🔹**ECS Cluster - Infrastructure (Capacity Providers):**

<p align="center">
  <img src="./doc/images/ECS-Cluster-Servics-Infrastructure.-cps-cp_name.png" alt="LEMP Diagram" width="900">
</p>

🔹**Application Load Balancer (HTTPS 443):**

<p align="center">
  <img src="./doc/images/ALB.png" alt="LEMP Diagram" width="900">
</p>

🔹**LB - Target Group:**

<p align="center">
  <img src="./doc/images/LB-Target-Group.png" alt="LEMP Diagram" width="900">
</p>

🔹**Auto Scaling Group:**

<p align="center">
  <img src="./doc/images/Ec2-ASG.png" alt="LEMP Diagram" width="900">
</p>

🔹**VPC:**

<p align="center">
  <img src="./doc/images/vpc.png" alt="LEMP Diagram" width="900">
</p>

---

#### Cleanup

- To avoid unnecessary costs, destroy the infrastructure when no longer needed
  
```bash
terraform destroy    
```

  ⭐ If you found this project interesting, consider giving it a star!

