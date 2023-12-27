resource "aws_route_table" "internet_egress_via_nat" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.vpc.id
  tags = { Name = "${var.environment_name}-rt-${count.index}" }
}

resource "aws_route" "nat-gateway-route" {
  count = length(var.availability_zones)

  route_table_id         = element(aws_route_table.internet_egress_via_nat[*].id, count.index)
  # nat_gateway_id         = element(aws_nat_gateway.nat[*].id, count.index)
  nat_gateway_id         = aws_nat_gateway.nat[count.index].id
  destination_cidr_block = "0.0.0.0/0"
}

# allow internet egress traffic via NAT gateway
resource "aws_route_table_association" "route-management-subnet" {
  count          = length(var.availability_zones)
  subnet_id      = element(aws_subnet.management-subnet[*].id, count.index)
  route_table_id = element(aws_route_table.internet_egress_via_nat[*].id, count.index)
}


resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

# allow internet traffic via Internet gateway
resource "aws_route_table_association" "route-public-subnet" {
  count          = length(var.availability_zones)
  subnet_id      = element(aws_subnet.infra-subnet[*].id, count.index)
  route_table_id = aws_route_table.public-route-table.id
}
