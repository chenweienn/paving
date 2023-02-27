locals {
  stable_config_tas = {
    lb_pool_web = nsxt_lb_pool.tas-web.display_name
    lb_pool_tcp = nsxt_lb_pool.tas-tcp.display_name
    lb_pool_ssh = nsxt_lb_pool.tas-ssh.display_name
  }
}

output "stable_config_tas" {
  value     = jsonencode(local.stable_config_tas)
  sensitive = true
}
