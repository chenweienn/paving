resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
  tags = { Name = "${var.environment_name}-Internet-gateway" }
}

resource "aws_eip" "nat" {
  count = length(var.availability_zones)
  domain = "vpc"
  tags = { Name = "${var.environment_name}-nat-eip-${count.index}" }
}

resource "aws_nat_gateway" "nat" {
  count = length(var.availability_zones)

  connectivity_type = "public"
  allocation_id = element(aws_eip.nat[*].id, count.index)
  subnet_id     = element(aws_subnet.infra-subnet[*].id, count.index)

  depends_on = [aws_internet_gateway.gw]
  tags = { Name = "${var.environment_name}-nat-gateway-${count.index}" }
}
