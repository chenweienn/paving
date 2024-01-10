resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { Name = "${var.environment_name}-vpc" }
}

# VPC endpoint for S3 access
resource "aws_vpc_endpoint" "s3" {
  vpc_id             = aws_vpc.vpc.id
  subnet_ids         = aws_subnet.infra-subnet[*].id
  service_name       = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type  = "Interface"
  security_group_ids = [ aws_security_group.allow_vpc.id ]
  tags = { Name = "${var.environment_name}-vpc-s3-endpoint" }
}
