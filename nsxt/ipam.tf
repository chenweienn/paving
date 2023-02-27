

resource "nsxt_ip_block" "container_ip_block" {
  description  = "Subnets are allocated from this pool to each newly-created TAS org"
  display_name = "${var.environment_name}-tas-container-ip-block"
  cidr         = "10.12.0.0/14"
}
