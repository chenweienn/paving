# remove aws_security_group.nat ?
resource "aws_security_group" "nat" {
  name   = "${var.environment_name}-nat-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    cidr_blocks = [aws_vpc.vpc.cidr_block]
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }

  tags = { "Name" = "${var.environment_name}-nat-sg" }
}

resource "aws_security_group" "ops-manager" {
  name   = "${var.environment_name}-ops-manager-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    cidr_blocks = var.ops_manager_allowed_ips
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
  }

  ingress {
    cidr_blocks = var.ops_manager_allowed_ips
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
  }

  ingress {
    cidr_blocks = var.ops_manager_allowed_ips
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
  }

  # allow ops manager -> BOSH agent on BOSH director VM
  #ingress {
  #  cidr_blocks = [aws_vpc.vpc.cidr_block]
  #  protocol    = "tcp"
  #  from_port   = 6868
  #  to_port     = 6868
  #}

  # allow all platform vms to BOSH api on BOSH director VM
  #ingress {
  #  cidr_blocks = [aws_vpc.vpc.cidr_block, concourse_vpc]
  #  protocol    = "tcp"
  #  from_port   = 25555
  #  to_port     = 25555
  #}

  # allow all platform vms to BOSH UAA on BOSH director VM
  #ingress {
  #  cidr_blocks = [aws_vpc.vpc.cidr_block, concourse_vpc]
  #  protocol    = "tcp"
  #  from_port   = 8443
  #  to_port     = 8443
  #}


  egress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }

  tags = { "Name" = "${var.environment_name}-ops-manager-sg" }
}

resource "aws_security_group" "platform" {
  name   = "${var.environment_name}-platform-vms-sg"
  vpc_id = aws_vpc.vpc.id

  # allow traffic from any TAS VPCs
  ingress {
    cidr_blocks = ["10.0.0.0/8"]
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }

  # allow cf ssh
  #ingress {
  #  cidr_blocks = ["0.0.0.0/0"]
  #  protocol    = "tcp"
  #  from_port   = 2222
  #  to_port     = 2222
  #}

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }

  tags = { "Name" = "${var.environment_name}-platform-vms-sg" }
}
