resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "${var.environment_name}-rds-subnet-group"
  description = "RDS Subnet Group"
  subnet_ids  = aws_subnet.infra-subnet[*].id
}

resource "random_string" "rds_password" {
  length  = 16
  special = false
}

resource "aws_db_instance" "concourse_db" {
  allocated_storage          = var.concourse_rds_allocated_storage
  max_allocated_storage      = var.concourse_rds_max_allocated_storage
  auto_minor_version_upgrade = false
  db_subnet_group_name       = aws_db_subnet_group.rds_subnet_group.name
  engine                     = var.concourse_rds_engine
  engine_version             = var.concourse_rds_engine_version
  identifier                 = var.concourse_rds_identifier
  instance_class             = var.concourse_rds_instance_class
  multi_az                   = var.concourse_rds_multi_az
  publicly_accessible        = var.concourse_rds_publicly_accessible
  storage_type               = var.concourse_rds_storage_type
  skip_final_snapshot        = true
  username                   = "concourse_admin"
  password                   = random_string.rds_password.result
  port                       = var.concourse_rds_port
  vpc_security_group_ids     = [aws_security_group.concourse_db_sg.id]
}

provider "curl" {}

data "curl" "rds_ca_cert" {
  http_method = "GET"
  uri = "https://truststore.pki.rds.amazonaws.com/${var.region}/${var.region}-bundle.pem"
}
