# Transit Gateway
resource "aws_ec2_transit_gateway" "tgw" {
  description = "The transit gateway in region ${var.region}"
  tags = { Name = "${var.environment_name}-tgw" }
}

# VPC attachment
resource "aws_ec2_transit_gateway_vpc_attachment" "vpca" {
  subnet_ids         = aws_subnet.infra-subnet[*].id
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.vpc.id
  tags = { Name = "${var.environment_name}-tgw-vpc-attachment" }
}
