locals {
  config = {
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

    tas_subnets = [
      for i in range(length(var.availability_zones)) :
        {
          subnet_id                = aws_subnet.tas-subnet[i].id
          subnet_cidr              = aws_subnet.tas-subnet[i].cidr_block
          subnet_reserved_ip_range = "${cidrhost(aws_subnet.tas-subnet[i].cidr_block, 0)}-${cidrhost(aws_subnet.tas-subnet[i].cidr_block, 9)}"
          subnet_gateway           = cidrhost(aws_subnet.tas-subnet[i].cidr_block, 1)
          subnet_az                = aws_subnet.tas-subnet[i].availability_zone
        }
    ]

    services_subnets = [
      for i in range(length(var.availability_zones)) :
        {
          subnet_id                = aws_subnet.services-subnet[i].id
          subnet_cidr              = aws_subnet.services-subnet[i].cidr_block
          subnet_reserved_ip_range = "${cidrhost(aws_subnet.services-subnet[i].cidr_block, 0)}-${cidrhost(aws_subnet.services-subnet[i].cidr_block, 9)}"
          subnet_gateway           = cidrhost(aws_subnet.services-subnet[i].cidr_block, 1)
          subnet_az                = aws_subnet.services-subnet[i].availability_zone
        }
    ]

    ops_manager_subnet_id                 = aws_subnet.management-subnet[0].id
    ops_manager_public_ip                 = aws_eip.ops-manager.public_ip
    ops_manager_dns                       = aws_route53_record.ops-manager.name
    #ops_manager_iam_user_access_key       = aws_iam_access_key.ops-manager.id
    #ops_manager_iam_user_secret_key       = aws_iam_access_key.ops-manager.secret
    ops_manager_iam_instance_profile_name = aws_iam_instance_profile.ops-manager.name
    ec2_ssh_key_pair_name                 = aws_key_pair.ssh_key.key_name
    ec2_ssh_public_key                    = tls_private_key.ssh_key.public_key_openssh
    ec2_ssh_private_key                   = tls_private_key.ssh_key.private_key_pem
    ops_manager_security_group_id         = aws_security_group.ops-manager.id
    ops_manager_security_group_name       = aws_security_group.ops-manager.name

    platform_vms_security_group_id   = aws_security_group.platform.id
    platform_vms_security_group_name = aws_security_group.platform.name

    allow_vpc_security_group_id   = aws_security_group.allow_vpc.id
    allow_vpc_security_group_name = aws_security_group.allow_vpc.name

    #ssl_certificate = var.ssl_certificate
    #ssl_private_key = var.ssl_private_key

    vpc_s3_endpoint        = replace(aws_vpc_endpoint.s3.dns_entry[0]["dns_name"],"*","bucket")

    bosh_bucket            = aws_s3_bucket.buckets["bosh-bucket"].bucket
    bbr_backups_bucket     = aws_s3_bucket.buckets["bbr-backups"].bucket
    buildpacks_bucket      = aws_s3_bucket.buckets["buildpacks"].bucket
    droplets_bucket        = aws_s3_bucket.buckets["droplets"].bucket
    packages_bucket        = aws_s3_bucket.buckets["packages"].bucket
    resources_bucket       = aws_s3_bucket.buckets["resources"].bucket

    s3_encryption_key_id   = aws_kms_key.s3-encryption-key.key_id

    tas_blobstore_iam_instance_profile_name = aws_iam_instance_profile.tas-blobstore.name

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
    tas_db_ca_cert  = data.curl.rds_ca_cert.response

    tas_db_secret   = {
      tas_db_endpoint = aws_db_instance.tas_db.endpoint
      tas_db_username = aws_db_instance.tas_db.username
      tas_db_password = random_string.rds_password.result
    }

    tas_db_security_group_id = aws_security_group.tas_db_sg.id
    tas_db_security_group_name = aws_security_group.tas_db_sg.name

    sys_dns_domain = replace(aws_route53_record.wildcard-sys.name, "*.", "")
    apps_dns_domain = replace(aws_route53_record.wildcard-apps.name, "*.", "")
    ssh_dns = aws_route53_record.ssh.name
    tcp_dns = aws_route53_record.tcp.name
  }
}

output "config" {
  value     = jsonencode(local.config)
  sensitive = true
}

# persist tas_db_secret in AWS Secret Manager

resource "aws_secretsmanager_secret" "tas-db-secret" {
  provider    = aws.plat-auto
  name_prefix = "/concourse/sandbox/tas-db-credential-"
  description = "TAS DB credential"
}

resource "aws_secretsmanager_secret_version" "tas-db-secret-version" {
  provider      = aws.plat-auto
  secret_id     = aws_secretsmanager_secret.tas-db-secret.id
  secret_string = jsonencode(local.config.tas_db_secret)
}
