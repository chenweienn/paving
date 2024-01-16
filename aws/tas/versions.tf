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
}
