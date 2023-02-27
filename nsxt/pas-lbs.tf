resource "nsxt_lb_http_monitor" "tas-web" {
  description           = "The Active Health Monitor (healthcheck) for Web (HTTP(S)) traffic."
  display_name          = "${var.environment_name}-tas-web-monitor"
  monitor_port          = 8080
  request_method        = "GET"
  request_url           = "/health"
  request_version       = "HTTP_VERSION_1_1"
  response_status_codes = [200]

  tag {
    scope = "terraform"
    tag   = var.environment_name
  }
}

resource "nsxt_lb_http_monitor" "tas-tcp" {
  description     = "The Active Health Monitor (healthcheck) for TCP traffic."
  display_name    = "${var.environment_name}-tas-tcp-monitor"
  monitor_port    = 80
  request_method  = "GET"
  request_url     = "/health"
  request_version = "HTTP_VERSION_1_1"

  tag {
    scope = "terraform"
    tag   = var.environment_name
  }
  response_status_codes = [200]
}

resource "nsxt_lb_tcp_monitor" "tas-ssh" {
  description  = "The Active Health Monitor (healthcheck) for SSH traffic."
  display_name = "${var.environment_name}-tas-ssh-monitor"
  monitor_port = 2222

  tag {
    scope = "terraform"
    tag   = var.environment_name
  }
}

resource "nsxt_lb_pool" "tas-web" {
  description              = "The Server Pool of Web (HTTP(S)) traffic handling VMs"
  display_name             = "${var.environment_name}-tas-web-pool"
  algorithm                = "ROUND_ROBIN"
  tcp_multiplexing_enabled = false
  active_monitor_id        = nsxt_lb_http_monitor.tas-web.id

  snat_translation {
    type = "SNAT_AUTO_MAP"
  }

  tag {
    scope = "terraform"
    tag   = var.environment_name
  }
}

resource "nsxt_lb_pool" "tas-tcp" {
  description              = "The Server Pool of TCP traffic handling VMs"
  display_name             = "${var.environment_name}-tas-tcp-pool"
  algorithm                = "ROUND_ROBIN"
  tcp_multiplexing_enabled = false
  active_monitor_id        = nsxt_lb_http_monitor.tas-tcp.id

  snat_translation {
    type = "TRANSPARENT"
  }

  tag {
    scope = "terraform"
    tag   = var.environment_name
  }
}

resource "nsxt_lb_pool" "tas-ssh" {
  description              = "The Server Pool of SSH traffic handling VMs"
  display_name             = "${var.environment_name}-tas-ssh-pool"
  algorithm                = "ROUND_ROBIN"
  tcp_multiplexing_enabled = false
  active_monitor_id        = nsxt_lb_tcp_monitor.tas-ssh.id

  snat_translation {
    type = "TRANSPARENT"
  }

  tag {
    scope = "terraform"
    tag   = var.environment_name
  }
}

resource "nsxt_lb_fast_tcp_application_profile" "tas_lb_tcp_application_profile" {
  display_name  = "${var.environment_name}-tas-lb-tcp-application-profile"
  close_timeout = "8"
  idle_timeout  = "1800"

  tag {
    scope = "terraform"
    tag   = var.environment_name
  }
}

resource "nsxt_lb_tcp_virtual_server" "lb_web_virtual_server" {
  description            = "The Virtual Server for Web (HTTP(S)) traffic"
  display_name           = "${var.environment_name}-tas-web-vs"
  application_profile_id = nsxt_lb_fast_tcp_application_profile.tas_lb_tcp_application_profile.id
  ip_address             = var.nsxt_lb_web_virtual_server_ip_address
  ports                  = ["80", "443"]
  pool_id                = nsxt_lb_pool.tas-web.id

  tag {
    scope = "terraform"
    tag   = var.environment_name
  }
}

resource "nsxt_lb_tcp_virtual_server" "lb_tcp_virtual_server" {
  description            = "The Virtual Server for TCP traffic"
  display_name           = "${var.environment_name}-tas-tcp-vs"
  application_profile_id = nsxt_lb_fast_tcp_application_profile.tas_lb_tcp_application_profile.id
  ip_address             = var.nsxt_lb_tcp_virtual_server_ip_address
  ports                  = var.nsxt_lb_tcp_virtual_server_ports
  pool_id                = nsxt_lb_pool.tas-tcp.id

  tag {
    scope = "terraform"
    tag   = var.environment_name
  }
}

resource "nsxt_lb_tcp_virtual_server" "lb_ssh_virtual_server" {
  description            = "The Virtual Server for SSH traffic"
  display_name           = "${var.environment_name}-tas-ssh-vs"
  application_profile_id = nsxt_lb_fast_tcp_application_profile.tas_lb_tcp_application_profile.id
  ip_address             = var.nsxt_lb_ssh_virtual_server_ip_address
  ports                  = ["2222"]
  pool_id                = nsxt_lb_pool.tas-ssh.id

  tag {
    scope = "terraform"
    tag   = var.environment_name
  }
}

resource "nsxt_lb_service" "tas_lb" {
  description  = "The Load Balancer for handling Web (HTTP(S)), TCP, and SSH traffic."
  display_name = "${var.environment_name}-tas-lb"

  enabled           = true
  logical_router_id = nsxt_logical_tier1_router.t1_deployment.id
  size              = "SMALL"
  virtual_server_ids = [
    nsxt_lb_tcp_virtual_server.lb_web_virtual_server.id,
    nsxt_lb_tcp_virtual_server.lb_tcp_virtual_server.id,
    nsxt_lb_tcp_virtual_server.lb_ssh_virtual_server.id
  ]

  depends_on = [
    nsxt_logical_router_link_port_on_tier1.t1_infrastructure_to_t0,
    nsxt_logical_router_link_port_on_tier1.t1_deployment_to_t0,
  ]

  tag {
    scope = "terraform"
    tag   = var.environment_name
  }
}
