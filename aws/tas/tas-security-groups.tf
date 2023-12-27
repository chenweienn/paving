resource "aws_security_group" "web_lb_sg" {
  name   = "${var.environment_name}-web-lb-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }
}

resource "aws_security_group" "ssh_lb_sg" {
  name   = "${var.environment_name}-ssh-lb-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
    from_port   = 2222
    to_port     = 2222
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }
}

resource "aws_security_group" "tcp_lb_sg" {
  name   = "${var.environment_name}-tcp-lb-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
    from_port   = split("-","${var.tcp_lb_ports}")[0]
    to_port     = split("-","${var.tcp_lb_ports}")[1]
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }
}

resource "aws_security_group" "tas_db_sg" {
  name   = "${var.environment_name}-tas-db-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    cidr_blocks = [aws_vpc.vpc.cidr_block]
    protocol    = "tcp"
    from_port   = var.tas_rds_port
    to_port     = var.tas_rds_port
  }

  egress {
    cidr_blocks = [aws_vpc.vpc.cidr_block]
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }
}
