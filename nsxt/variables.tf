variable "nsxt_host" {
  description = "The NSX-T host. Must resolve to a reachable IP address, e.g. `nsxmgr.example.tld`"
  type        = string
}

variable "nsxt_username" {
  description = "The NSX-T username, probably `admin`"
  type        = string
}

variable "nsxt_password" {
  description = "The NSX-T password"
  type        = string
}


variable "allow_unverified_ssl" {
  default     = false
  description = "Allow connection to NSX-T manager with self-signed certificates. Set to `true` for POC or development environments"
  type        = string
}

variable "environment_name" {
  description = "An identifier used to tag resources; examples: `dev`, `EMEA`, `prod`"
  type        = string
}

variable "east_west_transport_zone_name" {
  description = "The name of the Transport Zone that carries internal traffic between the NSX-T components. Also known as the `overlay` transport zone"
  type        = string
}



variable "nsxt_edge_cluster_name" {
  description = "The name of the deployed Edge Cluster, e.g. `edge-cluster-1`"
  type        = string
}

variable "nsxt_t0_router_name" {
  default     = "T0-Router"
  description = "The name of the T0 router"
  type        = string
}

variable "nat_gateway_ip" {
  description = "The IP Address of the SNAT rule for egress traffic from the Infrastructure, Deployment, services subnets; should be in the same subnet as the external IP pool, but not in the range of available IP addresses, e.g. `10.195.74.17`"
  type        = string
}

variable "nsxt_lb_web_virtual_server_ip_address" {
  description = "The ip address on which the Virtual Server listens for Web (HTTP(S)) traffic, should be in the same subnet as the external IP pool, but not in the range of available IP addresses, e.g. `10.195.74.17`"
  type        = string
}

variable "nsxt_lb_tcp_virtual_server_ip_address" {
  description = "The ip address on which the Virtual Server listens for TCP traffic, should be in the same subnet as the external IP pool, but not in the range of available IP addresses, e.g. `10.195.74.19`"
  type        = string
}

variable "nsxt_lb_tcp_virtual_server_ports" {
  description = "The list of port(s) on which the Virtual Server listens for TCP traffic, e.g. `[\"8080\", \"52135\", \"34000-35000\"]`"
  type        = list(string)
}

variable "nsxt_lb_ssh_virtual_server_ip_address" {
  description = "The ip address on which the Virtual Server listens for SSH traffic, should be in the same subnet as the external IP pool, but not in the range of available IP addresses, e.g. `10.195.74.18`"
  type        = string
}

variable "ops_manager_public_ip" {
  description = "The public IP Address of the Operations Manager. The om's DNS (e.g. `om.system.tld`) should resolve to this IP, e.g. `10.195.74.16`"
  type        = string
}

variable "subnet_prefix" {
  description = "The private /24 subnets of Infrastructure/Deployment/Services networks are allocated from \"subnet_prefix.0.0/16\""
  type = string
  default = "192.168"
}
