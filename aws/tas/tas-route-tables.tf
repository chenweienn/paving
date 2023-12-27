# allow internet egress traffic via NAT gateway
resource "aws_route_table_association" "route-tas-subnet" {
  count          = length(var.availability_zones)
  subnet_id      = element(aws_subnet.tas-subnet[*].id, count.index)
  route_table_id = element(aws_route_table.internet_egress_via_nat[*].id, count.index)
}

resource "aws_route_table_association" "route-services-subnet" {
  count          = length(var.availability_zones)
  subnet_id      = element(aws_subnet.services-subnet[*].id, count.index)
  route_table_id = element(aws_route_table.internet_egress_via_nat[*].id, count.index)
}
