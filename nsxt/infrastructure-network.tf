resource "nsxt_logical_router_link_port_on_tier0" "t0_to_t1_infrastructure" {
  display_name = "${var.environment_name}-T0-to-T1-Infrastructure"

  description       = "Link Port on Logical Tier-0 Router for connecting to Infrastructure Tier-1 Router."
  logical_router_id = data.nsxt_logical_tier0_router.t0_router.id

  tag {
    scope = "terraform"
    tag   = var.environment_name
  }
}

resource "nsxt_logical_tier1_router" "t1_infrastructure" {
  display_name = "${var.environment_name}-Infrastructure-T1-Router"

  description = "Infrastructure Tier-1 Router."
  failover_mode   = "PREEMPTIVE"
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

resource "nsxt_logical_router_link_port_on_tier1" "t1_infrastructure_to_t0" {
  display_name = "${var.environment_name}-T1-Infrastructure-to-T0"

  description                   = "Link Port on Infrastructure Tier-1 Router connecting to Logical Tier-0
Router. Provisioned by Terraform."
  logical_router_id             = nsxt_logical_tier1_router.t1_infrastructure.id
  linked_logical_router_port_id = nsxt_logical_router_link_port_on_tier0.t0_to_t1_infrastructure.id

  tag {
    scope = "terraform"
    tag   = var.environment_name
  }
}

resource "nsxt_logical_switch" "ls_infrastructure" {                                                         display_name = "${var.environment_name}-LogicalSwitch-Infrastructure"

  transport_zone_id = data.nsxt_transport_zone.east-west-overlay.id
  admin_state       = "UP"

  description      = "Logical Switch for the Infrastructure Tier-1 Router."
  replication_mode = "MTEP"

  tag {
    scope = "terraform"
    tag   = var.environment_name
  }
}

resource "nsxt_logical_port" "lp_on_ls_infrastructure" {
  display_name = "${var.environment_name}-LogicalSwitch-Infrastructure-lp"

  admin_state       = "UP"
  description       = "Logical Port on the Logical Switch for the Infrastructure Tier-1 Router."
  logical_switch_id = nsxt_logical_switch.ls_infrastructure.id

  tag {
    scope = "terraform"
    tag   = var.environment_name
  }
}

resource "nsxt_logical_router_downlink_port" "dp_on_t1_infrastructure" {
  display_name = "${var.environment_name}-Infrastructure-T1-dp"

  description                   = "Downlink port connecting Infrastructure Tier-1 router to its Logical Switch"
  logical_router_id             = nsxt_logical_tier1_router.t1_infrastructure.id
  linked_logical_switch_port_id = nsxt_logical_port.lp_on_ls_infrastructure.id
  ip_address                    = "${var.subnet_prefix}.1.1/24"

  tag {
    scope = "terraform"
    tag   = var.environment_name
  }
}


