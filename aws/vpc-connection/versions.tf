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
  }
  required_version = "~> 1.0"
  backend "s3" {
    bucket = "weien-tfstate"
    key    = "vpc-connection/terraform.tfstate"
    region = "us-east-1"
  }
}
