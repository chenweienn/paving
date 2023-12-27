locals {
  stable_config_tas = {
    tas_subnet_ids = aws_subnet.tas-subnet[*].id
    tas_subnet_cidrs = aws_subnet.tas-subnet[*].cidr_block
    tas_subnet_gateways = [
      for i in range(length(var.availability_zones)) :
      cidrhost(aws_subnet.tas-subnet[i].cidr_block, 1)
    ]
    tas_subnet_reserved_ip_ranges = [
      for i in range(length(var.availability_zones)) :
      "${cidrhost(aws_subnet.tas-subnet[i].cidr_block, 1)}-${cidrhost(aws_subnet.tas-subnet[i].cidr_block, 9)}"
    ]

    services_subnet_ids   = aws_subnet.services-subnet[*].id
    services_subnet_cidrs = aws_subnet.services-subnet[*].cidr_block
    services_subnet_gateways = [
      for i in range(length(var.availability_zones)) :
      cidrhost(aws_subnet.services-subnet[i].cidr_block, 1)
    ]
    services_subnet_reserved_ip_ranges = [
      for i in range(length(var.availability_zones)) :
      "${cidrhost(aws_subnet.services-subnet[i].cidr_block, 1)}-${cidrhost(aws_subnet.services-subnet[i].cidr_block, 9)}"
    ]

    buildpacks_bucket_name = aws_s3_bucket.buckets["buildpacks"].bucket
    droplets_bucket_name   = aws_s3_bucket.buckets["droplets"].bucket
    packages_bucket_name   = aws_s3_bucket.buckets["packages"].bucket
    resources_bucket_name  = aws_s3_bucket.buckets["resources"].bucket
    # tas_blobstore_iam_instance_profile_name = aws_iam_instance_profile.pas-blobstore.name

    ssh_lb_security_group_id = aws_security_group.ssh_lb_sg.id
    ssh_lb_security_group_name = aws_security_group.ssh_lb_sg.name
    ssh_target_group_name = aws_lb_target_group.ssh.name

    tcp_lb_security_group_id = aws_security_group.tcp_lb_sg.id
    tcp_lb_security_group_name = aws_security_group.tcp_lb_sg.name
    tcp_target_group_names = [
      for k,v in aws_lb_target_group.tcp : v.name
    ]

    web_lb_security_group_id = aws_security_group.web_lb_sg.id
    web_lb_security_group_name = aws_security_group.web_lb_sg.name
    web_target_group_names = [
      aws_lb_target_group.web-80.name,
      aws_lb_target_group.web-443.name
    ]

    tas_db_hostname = aws_db_instance.tas_db.address
    tas_db_port = aws_db_instance.tas_db.port
    tas_db_endpoint = aws_db_instance.tas_db.endpoint
    tas_db_username = aws_db_instance.tas_db.username
    tas_db_password = random_string.rds_password.result

    tas_db_security_group_id = aws_security_group.tas_db_sg.id
    tas_db_security_group_name = aws_security_group.tas_db_sg.name

    sys_dns_domain = replace(aws_route53_record.wildcard-sys.name, "*.", "")
    apps_dns_domain = replace(aws_route53_record.wildcard-apps.name, "*.", "")
    ssh_dns = aws_route53_record.ssh.name
    tcp_dns = aws_route53_record.tcp.name
  }
}

output "stable_config_tas" {
  value = jsonencode(local.stable_config_tas)
  sensitive = true
}
