# infra subnets host AWS NAT gateway, ELBs, RDS instances
resource "aws_subnet" "infra-subnet" {
  count = length(var.infra_subnet_cidrs)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.infra_subnet_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = { Name = "${var.environment_name}-infra-subnet-${count.index}" }
}

# management subnets host Ops Manager, BOSH director, BOSH director's compilation VMs
resource "aws_subnet" "management-subnet" {
  count = length(var.management_subnet_cidrs)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.management_subnet_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = { Name = "${var.environment_name}-management-subnet-${count.index}" }
}


resource "aws_subnet" "tas-subnet" {
  count = length(var.tas_subnet_cidrs)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.tas_subnet_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = { Name = "${var.environment_name}-tas-subnet-${count.index}" }
}

resource "aws_subnet" "services-subnet" {
  count = length(var.services_subnet_cidrs)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.services_subnet_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = { Name = "${var.environment_name}-services-subnet-${count.index}" }
}
