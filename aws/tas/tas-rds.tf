resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "${var.environment_name}-rds-subnet-group"
  description = "RDS Subnet Group"
  subnet_ids  = aws_subnet.infra-subnet[*].id
}

resource "random_string" "rds_password" {
  length  = 16
  special = false
}

resource "aws_db_instance" "tas_db" {
  allocated_storage          = var.tas_rds_allocated_storage
  max_allocated_storage      = var.tas_rds_max_allocated_storage
  auto_minor_version_upgrade = false
  db_subnet_group_name       = aws_db_subnet_group.rds_subnet_group.name
  engine                     = var.tas_rds_engine
  engine_version             = var.tas_rds_engine_version
  identifier                 = var.tas_rds_identifier
  instance_class             = var.tas_rds_instance_class
  iops                       = var.tas_rds_iops
  multi_az                   = var.tas_rds_multi_az
  publicly_accessible        = var.tas_rds_publicly_accessible
  storage_type               = var.tas_rds_storage_type
  skip_final_snapshot        = true
  username                   = "admin"
  password                   = random_string.rds_password.result
  port                       = var.tas_rds_port
  vpc_security_group_ids     = [aws_security_group.tas_db_sg.id]
}
