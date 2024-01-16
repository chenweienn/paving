
## Transit Gateway
data "aws_ec2_transit_gateway" "first" {
  provider = aws.first
  id = var.tgw_id_1
}
data "aws_ec2_transit_gateway" "second" {
  provider = aws.second
  id = var.tgw_id_2
}
# moved to Plat-Auto env terraform scripts
#resource "aws_ec2_transit_gateway" "first" {
#  provider = aws.first
#  description = "The transit gateway in region ${var.region_1}"
#  tags = { Name = "${var.environment_name_1}-tgw" }
#}
#resource "aws_ec2_transit_gateway" "second" {
#  provider = aws.second
#  description = "The transit gateway in region ${var.region_2}"
#  tags = { Name = "${var.environment_name_2}-tgw" }
#}

## VPC attachment
# moved to Plat-Auto env terraform scripts
#resource "aws_ec2_transit_gateway_vpc_attachment" "first" {
#  provider = aws.first
#  subnet_ids         = var.vpc_attachment_subnet_ids_1
#  transit_gateway_id = aws_ec2_transit_gateway.first.id
#  vpc_id             = var.vpc_id_1
#  tags = { Name = "${var.environment_name_1}-tgw-vpc-attachment" }
#}
#resource "aws_ec2_transit_gateway_vpc_attachment" "second" {
#  provider = aws.second
#  subnet_ids         = var.vpc_attachment_subnet_ids_2
#  transit_gateway_id = aws_ec2_transit_gateway.second.id
#  vpc_id             = var.vpc_id_2
#  tags = { Name = "${var.environment_name_2}-tgw-vpc-attachment" }
#}

# peering connection attachment
resource "aws_ec2_transit_gateway_peering_attachment" "requestor" {
  provider = aws.second
  peer_region             = var.region_1
  peer_transit_gateway_id = data.aws_ec2_transit_gateway.first.id
  transit_gateway_id      = data.aws_ec2_transit_gateway.second.id

  tags = {
    Name = "TGW Peering Requestor"
  }
}
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "acceptor" {
  provider = aws.first

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.requestor.id
  tags = {
    Name = "TGW Peering Acceptor"
  }
}

# update route tables of transit gateway
data "aws_vpc" "first" {
  provider = aws.first
  id = var.vpc_id_1
}
data "aws_vpc" "second" {
  provider = aws.second
  id = var.vpc_id_2
}

resource "aws_ec2_transit_gateway_route" "first" {
  provider = aws.first
  destination_cidr_block         = data.aws_vpc.second.cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.requestor.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway.first.association_default_route_table_id

  # the dependency is explained here: https://github.com/hashicorp/terraform-provider-aws/issues/14228
  depends_on = [ aws_ec2_transit_gateway_peering_attachment_accepter.acceptor ]
}

resource "aws_ec2_transit_gateway_route" "second" {
  provider = aws.second
  destination_cidr_block         = data.aws_vpc.first.cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.acceptor.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway.second.association_default_route_table_id
}


# update route tables of VPC subnets
data "aws_route_tables" "rts_first" {
  provider = aws.first
  vpc_id   = var.vpc_id_1

  filter {
    name   = "tag:Name"
    values = ["*infra-subnet-rt*","*mgmt-subnet-rt*"]
  }
}

resource "aws_route" "r_first" {
  provider = aws.first
  count                     = length(data.aws_route_tables.rts_first.ids)
  route_table_id            = tolist(data.aws_route_tables.rts_first.ids)[count.index]
  destination_cidr_block    = data.aws_vpc.second.cidr_block
  transit_gateway_id        = data.aws_ec2_transit_gateway.first.id
}

data "aws_route_tables" "rts_second" {
  provider = aws.second
  vpc_id   = var.vpc_id_2

  filter {
    name   = "tag:Name"
    values = ["*infra-subnet-rt*","*mgmt-subnet-rt*"]
  }
}

resource "aws_route" "r_second" {
  provider = aws.second
  count                     = length(data.aws_route_tables.rts_second.ids)
  route_table_id            = tolist(data.aws_route_tables.rts_second.ids)[count.index]
  destination_cidr_block    = data.aws_vpc.first.cidr_block
  transit_gateway_id        = data.aws_ec2_transit_gateway.second.id
}




