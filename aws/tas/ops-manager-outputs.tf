locals {
  stable_config_opsmanager = {
    environment_name   = var.environment_name
    availability_zones = var.availability_zones
    region             = var.region

    vpc_id         = aws_vpc.vpc.id
    vpc_cidr       = aws_vpc.vpc.cidr_block
    vpc_dns_server = cidrhost(aws_vpc.vpc.cidr_block, 2)

    transit_gateway_id = aws_ec2_transit_gateway.tgw.id

    infra_subnets = [
      for i in range(length(var.availability_zones)) :
        {
          subnet_id                = aws_subnet.infra-subnet[i].id
          subnet_cidr              = aws_subnet.infra-subnet[i].cidr_block
          subnet_gateway           = cidrhost(aws_subnet.management-subnet[i].cidr_block, 1)
          subnet_az                = aws_subnet.management-subnet[i].availability_zone
        }
    ]

    management_subnets = [
      for i in range(length(var.availability_zones)) :
        {
          subnet_id                = aws_subnet.management-subnet[i].id
          subnet_cidr              = aws_subnet.management-subnet[i].cidr_block
          subnet_reserved_ip_range = "${cidrhost(aws_subnet.management-subnet[i].cidr_block, 0)}-${cidrhost(aws_subnet.management-subnet[i].cidr_block, 9)}"
          subnet_gateway           = cidrhost(aws_subnet.management-subnet[i].cidr_block, 1)
          subnet_az                = aws_subnet.management-subnet[i].availability_zone
        }
    ]

    ops_manager_subnet_id                 = aws_subnet.management-subnet[0].id
    ops_manager_public_ip                 = aws_eip.ops-manager.public_ip
    ops_manager_dns                       = aws_route53_record.ops-manager.name
    #ops_manager_iam_user_access_key       = aws_iam_access_key.ops-manager.id
    #ops_manager_iam_user_secret_key       = aws_iam_access_key.ops-manager.secret
    ops_manager_iam_instance_profile_name = aws_iam_instance_profile.ops-manager.name
    ops_manager_key_pair_name             = aws_key_pair.ops-manager.key_name
    ops_manager_ssh_public_key            = tls_private_key.ops-manager.public_key_openssh
    ops_manager_ssh_private_key           = tls_private_key.ops-manager.private_key_pem
    ops_manager_security_group_id         = aws_security_group.ops-manager.id
    ops_manager_security_group_name       = aws_security_group.ops-manager.name

    platform_vms_security_group_id   = aws_security_group.platform.id
    platform_vms_security_group_name = aws_security_group.platform.name

    allow_vpc_security_group_id   = aws_security_group.allow_vpc.id
    allow_vpc_security_group_name = aws_security_group.allow_vpc.name

    #ssl_certificate = var.ssl_certificate
    #ssl_private_key = var.ssl_private_key

    bosh_bucket                           = aws_s3_bucket.bosh-bucket.bucket
    vpc_s3_endpoint                       = replace(aws_vpc_endpoint.s3.dns_entry[0]["dns_name"],"*","bucket")
  }
}

output "stable_config_opsmanager" {
  value     = jsonencode(local.stable_config_opsmanager)
  sensitive = true
}
