## management subnets route tables
resource "aws_route_table" "mgmt-subnet-route-tables" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.vpc.id
  tags = { Name = "${var.environment_name}-mgmt-subnet-rt-${count.index}" }
}

# allow internet egress traffic via NAT gateway
resource "aws_route" "nat-gateway-route" {
  count = length(var.availability_zones)

  route_table_id         = element(aws_route_table.mgmt-subnet-route-tables[*].id, count.index)
  # nat_gateway_id         = element(aws_nat_gateway.nat[*].id, count.index)
  nat_gateway_id         = aws_nat_gateway.nat[count.index].id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "route-management-subnet" {
  count          = length(var.availability_zones)
  subnet_id      = element(aws_subnet.management-subnet[*].id, count.index)
  route_table_id = element(aws_route_table.mgmt-subnet-route-tables[*].id, count.index)
}


## infra subnets route table
resource "aws_route_table" "infra-subnet-route-table" {
  vpc_id = aws_vpc.vpc.id
  tags = { Name = "${var.environment_name}-infra-subnet-rt" }
}

# allow internet traffic via Internet gateway
resource "aws_route" "internet-gateway-route" {
  route_table_id         = aws_route_table.infra-subnet-route-table.id
  gateway_id             = aws_internet_gateway.gw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "route-infra-subnet" {
  count          = length(var.availability_zones)
  subnet_id      = element(aws_subnet.infra-subnet[*].id, count.index)
  route_table_id = aws_route_table.infra-subnet-route-table.id
}