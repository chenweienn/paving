resource "nsxt_logical_router_link_port_on_tier0" "t0_to_t1_services" {
  display_name = "${var.environment_name}-T0-to-T1-Services"

  description       = "Link Port on Logical Tier-0 Router for connecting to Services Tier-1 Router."
  logical_router_id = data.nsxt_logical_tier0_router.t0_router.id

  tag {
    scope = "terraform"
    tag   = var.environment_name
  }
}

resource "nsxt_logical_tier1_router" "t1_services" {
  display_name = "${var.environment_name}-Services-T1-Router"

  description     = "Services Tier-1 Router."
  failover_mode   = "NON_PREEMPTIVE"
  edge_cluster_id = data.nsxt_edge_cluster.edge_cluster.id

  enable_router_advertisement = true
  advertise_connected_routes  = true
  advertise_lb_vip_routes     = true
  advertise_lb_snat_ip_routes = true

  tag {
    scope = "terraform"
    tag   = var.environment_name
  }
}

resource "nsxt_logical_router_link_port_on_tier1" "t1_services_to_t0" {
  display_name = "${var.environment_name}-T1-Services-to-T0"

  description                   = "Link Port on Services Tier-1 Router connecting to Logical Tier-0 Router. Provisioned by Terraform."
  logical_router_id             = nsxt_logical_tier1_router.t1_services.id
  linked_logical_router_port_id = nsxt_logical_router_link_port_on_tier0.t0_to_t1_services.id
                                                                                                            tag {
    scope = "terraform"
    tag   = var.environment_name
  }
}

resource "nsxt_logical_switch" "ls_services" {
  display_name = "${var.environment_name}-LogicalSwitch-Services"

  transport_zone_id = data.nsxt_transport_zone.east-west-overlay.id
  admin_state       = "UP"

  description      = "Logical Switch for the Services Tier-1 Router."
  replication_mode = "MTEP"

  tag {
    scope = "terraform"
    tag   = var.environment_name
  }
}

resource "nsxt_logical_port" "lp_on_ls_services" {
  display_name = "${var.environment_name}-LogicalSwitch-Services-lp"

  admin_state       = "UP"
  description       = "Logical Port on the Logical Switch for the Services Tier-1 Router."
  logical_switch_id = nsxt_logical_switch.ls_services.id

  tag {
    scope = "terraform"
    tag   = var.environment_name
  }
}

resource "nsxt_logical_router_downlink_port" "dp_on_t1_services" {
  display_name = "${var.environment_name}-Services-T1-dp"

  description                   = "Downlink port connecting Services Tier-1 router to its Logical Switch"
  logical_router_id             = nsxt_logical_tier1_router.t1_services.id
  linked_logical_switch_port_id = nsxt_logical_port.lp_on_ls_services.id
  ip_address                    = "${var.subnet_prefix}.3.1/24"

  tag {
    scope = "terraform"
    tag   = var.environment_name
  }
}
