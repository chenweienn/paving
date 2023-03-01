resource "nsxt_lb_http_monitor" "tas-web" {
  description           = "The Active Health Monitor (healthcheck) for Web (HTTP(S)) traffic."
  display_name          = "tas-web-monitor"
  monitor_port          = 8080
  request_method        = "GET"
  request_url           = "/health"
  request_version       = "HTTP_VERSION_1_1"
  response_status_codes = [200]
}

resource "nsxt_lb_http_monitor" "tas-tcp" {
  description     = "The Active Health Monitor (healthcheck) for TCP traffic."
  display_name    = "tas-tcp-monitor"
  monitor_port    = 80
  request_method  = "GET"
  request_url     = "/health"
  request_version = "HTTP_VERSION_1_1"
  response_status_codes = [200]
}

resource "nsxt_lb_tcp_monitor" "tas-ssh" {
  description  = "The Active Health Monitor (healthcheck) for SSH traffic (cf ssh)."
  display_name = "tas-ssh-monitor"
  monitor_port = 2222
}

resource "nsxt_lb_fast_tcp_application_profile" "tas_lb_tcp_application_profile" {
  display_name  = "tas-lb-tcp-application-profile"
  close_timeout = "8"
  idle_timeout  = "1800"
}

resource "nsxt_lb_service" "tas_lb" {
  description  = "The Load Balancer for handling Web (HTTP(S)), TCP, and SSH traffic."
  display_name = "tas-load-balancer"

  enabled           = true
  error_log_level   = "ERROR"
  logical_router_id = nsxt_policy_tier1_gateway.tas-deployment-t1-gw.id
  size              = "SMALL"
  virtual_server_ids = [
    nsxt_lb_tcp_virtual_server.lb_web_virtual_server.id,
    nsxt_lb_tcp_virtual_server.lb_tcp_virtual_server.id,
    nsxt_lb_tcp_virtual_server.lb_ssh_virtual_server.id
  ]

  depends_on = [
    nsxt_policy_tier1_gateway.tas-deployment-t1-gw
  ]
}

resource "nsxt_lb_tcp_virtual_server" "lb_web_virtual_server" {
  description               = "The Virtual Server for Web (HTTP(S)) traffic"
  display_name              = "tas-web-vs"
  application_profile_id    = nsxt_lb_fast_tcp_application_profile.tas_lb_tcp_application_profile.id
  ip_address                = var.tas_lb_web_virtual_server_ip_address
  ports                     = ["80", "443"]
  default_pool_member_ports = ["80", "443"]
  pool_id                   = nsxt_lb_pool.tas-web.id
  access_log_enabled        = true
}

resource "nsxt_lb_tcp_virtual_server" "lb_tcp_virtual_server" {
  description               = "The Virtual Server for TCP traffic"
  display_name              = "tas-tcp-vs"
  application_profile_id    = nsxt_lb_fast_tcp_application_profile.tas_lb_tcp_application_profile.id
  ip_address                = var.tas_lb_tcp_virtual_server_ip_address
  ports                     = var.tas_lb_tcp_virtual_server_ports
  default_pool_member_ports = var.tas_lb_tcp_virtual_server_ports
  pool_id                   = nsxt_lb_pool.tas-tcp.id
  access_log_enabled        = true
}

resource "nsxt_lb_tcp_virtual_server" "lb_ssh_virtual_server" {
  description               = "The Virtual Server for SSH traffic"
  display_name              = "tas-ssh-vs"
  application_profile_id    = nsxt_lb_fast_tcp_application_profile.tas_lb_tcp_application_profile.id
  ip_address                = var.tas_lb_ssh_virtual_server_ip_address
  ports                     = ["2222"]
  default_pool_member_ports = ["2222"]
  pool_id                   = nsxt_lb_pool.tas-ssh.id
  access_log_enabled        = true
}

resource "nsxt_lb_pool" "tas-web" {
  description              = "The Server Pool of Web (HTTP(S)) traffic (gorouters)"
  display_name             = "tas-web-pool"
  algorithm                = "ROUND_ROBIN"
  tcp_multiplexing_enabled = false
  active_monitor_id        = nsxt_lb_http_monitor.tas-web.id

  snat_translation {
    type = "SNAT_IP_POOL"
    ip   = var.tas_lb_web_virtual_server_ip_address
  }

  lifecycle {
    ignore_changes = [member]
  }
}

resource "nsxt_lb_pool" "tas-tcp" {
  description              = "The Server Pool of TCP traffic handling VMs"
  display_name             = "tas-tcp-pool"
  algorithm                = "ROUND_ROBIN"
  tcp_multiplexing_enabled = false
  active_monitor_id        = nsxt_lb_http_monitor.tas-tcp.id

  snat_translation {
    type = "SNAT_IP_POOL"
    ip   = var.tas_lb_tcp_virtual_server_ip_address
  }

  lifecycle {
    ignore_changes = [member]
  }
}

resource "nsxt_lb_pool" "tas-ssh" {
  description              = "The Server Pool of SSH traffic handling VMs"
  display_name             = "tas-ssh-pool"
  algorithm                = "ROUND_ROBIN"
  tcp_multiplexing_enabled = false
  active_monitor_id        = nsxt_lb_tcp_monitor.tas-ssh.id

  snat_translation {
    type = "SNAT_IP_POOL"
    ip   = var.tas_lb_ssh_virtual_server_ip_address
  }

  lifecycle {
    ignore_changes = [member]
  }
}
