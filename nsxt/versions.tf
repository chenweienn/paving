terraform {
  required_providers {
    nsxt = {
      source = "vmware/nsxt"
      version = "~> 3.3.0"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
  required_version = ">= 0.13"
}
