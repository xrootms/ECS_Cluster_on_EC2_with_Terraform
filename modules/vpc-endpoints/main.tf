####################################################
# Create VPC Endpoints for following Services
# com.amazonaws.${var.aws_region}.ecs-agent     - VPC Interface Endpoint  
# com.amazonaws.${var.aws_region}.ecs-telemetry - VPC Interface Endpoint
# com.amazonaws.${var.aws_region}.ecs           - VPC Interface Endpoint
# com.amazonaws.${var.aws_region}.ecr.dkr       - VPC Interface Endpoint
# com.amazonaws.${var.aws_region}.ecr.api       - VPC Interface Endpoint
# com.amazonaws.${var.aws_region}.logs          - VPC Interface Endpoint
# com.amazonaws.${var.aws_region}.s3            - VPC Gateway Endpoint
####################################################
locals {
  endpoint_list = ["com.amazonaws.${var.aws_region}.ecs-agent",
    "com.amazonaws.${var.aws_region}.ecs-telemetry",
    "com.amazonaws.${var.aws_region}.ecs",
    "com.amazonaws.${var.aws_region}.ecr.dkr",
    "com.amazonaws.${var.aws_region}.ecr.api",
    "com.amazonaws.${var.aws_region}.logs",
  ]
}


####################################################
# Create the VPC endpoints
####################################################
resource "aws_vpc_endpoint" "vpc_endpoint" {
  count               = 6
  vpc_id              = var.vpc_id
  vpc_endpoint_type   = "Interface"
  service_name        = local.endpoint_list[count.index]
  subnet_ids          = var.private_subnets[*] # AWS creates & attaches one endpoint ENI in that subnet.
  private_dns_enabled = true
  security_group_ids  = [var.sg_for_vpc_endpoints_https] # Attaches your endpoint-SG to the endpoint ENIs.


  tags = merge(var.common_tags, {
    Name = "${var.naming_prefix}-Endpoint-${local.endpoint_list[count.index]}"
  })
}

####################################################
# Create VPC Gateway Endpoint for S3
####################################################
resource "aws_vpc_endpoint" "vpc_endpoint_s3" {
  vpc_id            = var.vpc_id
  vpc_endpoint_type = "Gateway"
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids   = [var.private_route_table_id] #Attach the S3 Gateway endpoint to this route table.

  tags = merge(var.common_tags, {
    Name = "${var.naming_prefix}-Endpoint-com.amazonaws.${var.aws_region}.s3"
  })
}