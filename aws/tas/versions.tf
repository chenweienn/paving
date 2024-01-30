terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.28.0"
    }
    random = {
      source = "hashicorp/random"
    }
    tls = {
      source = "hashicorp/tls"
    }
    curl = {
      source  = "anschoewe/curl"
    }
  }
  required_version = "~> 1.0"
  backend "s3" {
    bucket = "weien-tfstate"
    key    = "sandbox-tas/terraform.tfstate"
    region = "us-east-1"
    assume_role = {
      role_arn = "arn:aws:iam::963973327276:role/svc.pcf-user"
    }
  }
}
