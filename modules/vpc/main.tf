
#setup vpc
resource "aws_vpc" "srl_proj_dev_vpc" {
  cidr_block       = var.vpc_cidr
  tags = { Name = var.vpc_name }
}

# setup public subnet
resource "aws_subnet" "srl_proj_dev_public_subnets"{
    count = length(var.cidr_public_subnet)
    vpc_id = aws_vpc.srl_proj_dev_vpc.id
    cidr_block = element(var.cidr_public_subnet, count.index)
    availability_zone = element(var.ap_availability_zone, count.index)
    tags = { Name = "srl_proj_dev_public_subnet-${count.index + 1}"}
}

# setup private subnet
resource "aws_subnet" "srl_proj_dev_private_subnets" {
  count = length(var.cidr_private_subnet)
  vpc_id = aws_vpc.srl_proj_dev_vpc.id
  cidr_block  = element(var.cidr_private_subnet, count.index)
  availability_zone = element(var.ap_availability_zone, count.index)
  tags = { Name = "srl_proj_dev_private_subnet-${count.index + 1}"}
}

# Setup Internet Gateway
resource "aws_internet_gateway" "srl_proj_dev_public_ig" {
  vpc_id = aws_vpc.srl_proj_dev_vpc.id
  tags = { Name  = "srl_proj_dev_ig" }
}

# Public Route-Table
resource "aws_route_table" "srl_proj_dev_public_route_table" {
  vpc_id = aws_vpc.srl_proj_dev_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.srl_proj_dev_public_ig.id
  }
  tags = { Name = "srl_proj_dev_public-rt" }
}

# Public rt and Public Subnet Association
resource "aws_route_table_association" "srl_proj_dev_public_rt_subnet_association" {
  count = length(aws_subnet.srl_proj_dev_public_subnets)
  subnet_id = aws_subnet.srl_proj_dev_public_subnets[count.index].id
  route_table_id = aws_route_table.srl_proj_dev_public_route_table.id
}

#Create an Elastic IP (EIP)
resource "aws_eip" "srl_proj_dev_nat_eip" {
  domain = "vpc"
  tags = { Name = "dev-proj-1-nat-eip" }
}

#Create NAT Gateway
resource "aws_nat_gateway" "srl_proj_dev_nat" {
  allocation_id = aws_eip.srl_proj_dev_nat_eip.id
  subnet_id     = aws_subnet.srl_proj_dev_public_subnets[0].id

  tags = { Name = "dev-proj-1-nat-gateway" }
}

# Private Route-Table
resource "aws_route_table" "srl_proj_dev_private_route_table" {
  vpc_id = aws_vpc.srl_proj_dev_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.srl_proj_dev_nat.id
  }
  tags = { Name = "srl_proj_dev_private-rt" }
}

# Private rt and private Subnet Association
resource "aws_route_table_association" "srl_proj_dev_private_rt_subnet_association" {
  count = length(aws_subnet.srl_proj_dev_private_subnets)
  subnet_id = aws_subnet.srl_proj_dev_private_subnets[count.index].id
  route_table_id = aws_route_table.srl_proj_dev_private_route_table.id
}