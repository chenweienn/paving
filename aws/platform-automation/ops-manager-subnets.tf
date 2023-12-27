# infra subnets host AWS NAT gateway, ELBs
resource "aws_subnet" "infra-subnet" {
  count = length(var.infra_subnet_cidrs)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.infra_subnet_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = { Name = "${var.environment_name}-infra-subnet-${count.index}" }
}

resource "aws_subnet" "management-subnet" {
  count = length(var.management_subnet_cidrs)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.management_subnet_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = { Name = "${var.environment_name}-management-subnet-${count.index}" }
}
