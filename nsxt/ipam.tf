resource "nsxt_ip_pool" "external_ip_pool" {
  description  = "IP Pool that provides IPs for each of the NSX-T container networks."
  display_name = "${var.environment_name}-external-ip-pool"

  subnet {
    allocation_ranges = var.external_ip_pool_ranges
    cidr              = var.external_ip_pool_cidr
    gateway_ip        = var.external_ip_pool_gateway
  }

  tag {
    scope = "terraform"
    tag   = var.environment_name
  }
}

resource "nsxt_ip_block" "container_ip_block" {
  description  = "Subnets are allocated from this pool to each newly-created Org"
  display_name = "${var.environment_name}-pas-container-ip-block"
  cidr         = "10.12.0.0/14"
}
