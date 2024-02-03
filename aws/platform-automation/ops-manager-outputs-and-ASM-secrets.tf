locals {
  terraform_result = {
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
          subnet_gateway           = cidrhost(aws_subnet.infra-subnet[i].cidr_block, 1)
          subnet_az                = aws_subnet.infra-subnet[i].availability_zone
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

    bosh_bucket_name                      = aws_s3_bucket.bosh-bucket.bucket
    bosh_bucket_region                    = aws_s3_bucket.bosh-bucket.region
    vpc_s3_endpoint                       = replace(aws_vpc_endpoint.s3.dns_entry[0]["dns_name"],"*","bucket")
  }
}

output "terraform_result" {
  value     = jsonencode(local.terraform_result)
  sensitive = true
}



## persist secrets in AWS Secret Manager

# pivnet_bucket_name

resource "aws_secretsmanager_secret" "pivnet_bucket_name" {
  name = "/concourse/pivnet_bucket_name"
  description = "Name of the S3 bucket used to store downloaded products from Tanzu Network (pivnet)"
}

resource "aws_secretsmanager_secret_version" "pivnet_bucket_name_version" {
  secret_id     = aws_secretsmanager_secret.pivnet_bucket_name.id
  secret_string = aws_s3_bucket.pivnet-bucket.bucket
}

# pivnet_bucket_region

resource "aws_secretsmanager_secret" "pivnet_bucket_region" {
  name = "/concourse/pivnet_bucket_region"
  description = "AWS region of the S3 bucket used to store downloaded products from Tanzu Network (pivnet)"
}

resource "aws_secretsmanager_secret_version" "pivnet_bucket_region_version" {
  secret_id     = aws_secretsmanager_secret.pivnet_bucket_region.id
  secret_string = aws_s3_bucket.pivnet-bucket.region
}

# plat_auto_vpc_s3_endpoint

resource "aws_secretsmanager_secret" "plat_auto_vpc_s3_endpoint" {
  name = "/concourse/plat_auto_vpc_s3_endpoint"
  description = "VPC interface endpoint to access S3 bucket from Plat Auto VPC."
}

resource "aws_secretsmanager_secret_version" "plat_auto_vpc_s3_endpoint_version" {
  secret_id     = aws_secretsmanager_secret.plat_auto_vpc_s3_endpoint.id
  secret_string = "https://${local.terraform_result.vpc_s3_endpoint}"
}





