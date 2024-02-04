variable "environment_name" {
  type = string
}

variable "region" {
  type = string
}

variable "hosted_zone" {
  description = "Hosted zone name (e.g. foo.example.com)"
  type        = string
}

variable "availability_zones" {
  description = "The list of availability zones to use. Must belong to the provided region and equal the number of CIDRs provided for each subnet."
  type        = list
}

variable "ssl_certificate" {
  default = ""
  type    = string
}

variable "ssl_private_key" {
  default = ""
  type    = string
}

variable "vpc_cidr" {
  default     = "10.0.0.0/20"
  description = "The IP CIDR for VPC."
  type        = string
}

variable "infra_subnet_cidrs" {
  default     = ["10.0.0.0/26", "10.0.0.64/26", "10.0.0.128/26"]
  description = "The list of CIDRs for the infra subnet which hosts AWS NAT gateway, ELBs. Number of CIDRs MUST match the number of AZs."
  type        = list
}

variable "management_subnet_cidrs" {
  default     = ["10.0.1.0/27", "10.0.1.32/27", "10.0.1.64/27"]
  description = "The list of CIDRs for the Management subnet. Number of CIDRs MUST match the number of AZs."
  type        = list
}

# no need, use auto-assignment
# variable "nat_gateway_private_ips" {
#   default     = ["10.0.1.6", "10.0.2.6", "10.0.3.6"]
#   description = "The list of private IPs allocated for NAT gateways provisioned in management subnets. Number of IPs MUST match the number of AZs."
#   type        = list
# }

variable "tas_subnet_cidrs" {
  default     = ["10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
  description = "The list of CIDRs for the TAS subnet. Number of CIDRs MUST match the number of AZs."
  type        = list
}

variable "services_subnet_cidrs" {
  default     = ["10.0.5.0/24", "10.0.6.0/24", "10.0.7.0/24"]
  description = "The list of CIDRs for the Services subnet. Number of CIDRs MUST match the number of AZs."
  type        = list
}

variable "ops_manager_allowed_ips" {
  description = "IPs allowed to communicate with Ops Manager."
  default     = ["0.0.0.0/0"]
  type        = list
}

# web-lb https listener config

variable "https_listener_ssl_policy" {
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  description = "ALB HTTPS listener security policy. See https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html"
  type        = string
}

variable "https_listener_cert_private_key_filename" {
  default     = "cert-key.pem"
  description = "The file which contains certificate private key (PEM-encoded) for ALB HTTPS listener. Prepare it in terraform working directory."
  type        = string
}

variable "https_listener_cert_body_filename" {
  default     = "cert.pem"
  description = "The file which contains the certificate (PEM-encoded) for ALB HTTPS listener. Prepare it in terraform working directory."
  type        = string
}

variable "https_listener_cert_chain_filename" {
  default     = "cert-chain.pem"
  description = "The file which contains the certificates chain (PEM-encoded) for ALB HTTPS listener. Prepare it in terraform working directory."
  type        = string
}


# TAS tcp routing ports
variable "tcp_lb_ports" {
  default     = "20000-20010"
  description = "The range of TCP ports to routing traffic via AWS NLB. Example, \"20000-20010\""
  type        = string
}

# concourse RDS options
variable "concourse_rds_engine" {
  default     = "postgres"
  description = "AWS RDS engine. Coucourse supports \"postgres\" only."
  type        = string
}

variable "concourse_rds_engine_version" {
  default     = "15.5"
  description = "AWS RDS engine version."
  type        = string
}

variable "concourse_rds_identifier" {
  default     = "concourse-db"
  description = "AWS RDS engine identifer."
  type        = string
}

variable "concourse_rds_instance_class" {
  default     = "db.t3.medium"
  description = "AWS RDS instance class."
  type        = string
}

variable "concourse_rds_allocated_storage" {
  default     = 20
  description = "AWS RDS allocated storage (GiB)."
  type        = number
}

variable "concourse_rds_max_allocated_storage" {
  default     = 40
  description = "AWS RDS max allocated storage (GiB). Must be greater than or equal to concourse_rds_allocated_storage."
  type        = number
}

variable "concourse_rds_multi_az" {
  default     = true
  description = "Specifies if the AWS RDS instance is multi-AZ."
  type        = bool
}

variable "concourse_rds_publicly_accessible" {
  default     = false
  description = "Bool to control if instance is publicly accessible."
  type        = bool
}

variable "concourse_rds_storage_type" {
  default     = "io1"
  description = "AWS RDS instance storage type."
  type        = string
}

variable "concourse_rds_port" {
  default     = 5432
  description = "The port on which the DB accepts connections."
  type        = number
}


variable "tags" {
  description = "Key/value tags to assign to all resources."
  default     = {}
  type        = map(string)
}

variable "assume_role_arn" {
  description = "The IAM role to assume by the authenticated IAM user"
  default     = ""
  type        = string
}

variable "role_session_name" {
  description = "See https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html"
  default     = ""
  type        = string
}