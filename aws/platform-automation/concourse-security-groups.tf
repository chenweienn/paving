resource "aws_security_group" "concourse_lb_sg" {
  name   = "${var.environment_name}-concourse-lb-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
    from_port   = 2222
    to_port     = 2222
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
    from_port   = 8443
    to_port     = 8443
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }

  tags = { "Name" = "${var.environment_name}-concourse-lb-sg" }
}

resource "aws_security_group" "concourse_db_sg" {
  name   = "${var.environment_name}-concourse-db-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    cidr_blocks = [aws_vpc.vpc.cidr_block]
    protocol    = "tcp"
    from_port   = var.concourse_rds_port
    to_port     = var.concourse_rds_port
  }

  egress {
    cidr_blocks = [aws_vpc.vpc.cidr_block]
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }

  tags = { "Name" = "${var.environment_name}-concourse-db-sg" }
}
