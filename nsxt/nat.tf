resource "nsxt_nat_rule" "snat_vm" {
  display_name = "${var.environment_name}-snat-vm"
  action       = "SNAT"

  logical_router_id = data.nsxt_logical_tier0_router.t0_router.id
  description       = "SNAT Rule for all VMs with exception of sockets coming in through LBs"
  enabled           = true
  logging           = false
  nat_pass          = true

  match_source_network = "${var.subnet_prefix}.0.0/16"
  translated_network   = var.nat_gateway_ip

  tag {
    scope = "terraform"
    tag   = var.environment_name
  }
}

resource "nsxt_nat_rule" "snat_om" {
  display_name = "${var.environment_name}-snat-om"
  action       = "SNAT"

  logical_router_id = data.nsxt_logical_tier0_router.t0_router.id
  description       = "SNAT Rule for Operations Manager"
  enabled           = true
  logging           = false
  nat_pass          = true

  match_source_network = "${var.subnet_prefix}.1.10"
  translated_network   = var.ops_manager_public_ip

  tag {
    scope = "terraform"
    tag   = var.environment_name
  }
}

resource "nsxt_nat_rule" "dnat_om" {
  display_name = "${var.environment_name}-dnat-om"
  action       = "DNAT"

  logical_router_id = data.nsxt_logical_tier0_router.t0_router.id
  description       = "DNAT Rule for Operations Manager"
  enabled           = true
  logging           = false
  nat_pass          = true

  match_destination_network = var.ops_manager_public_ip
  translated_network        = "${var.subnet_prefix}.1.10"

  tag {
    scope = "terraform"
    tag   = var.environment_name
  }
}
