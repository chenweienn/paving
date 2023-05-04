# terraform-tas-nsxt

[Terraform](https://www.terraform.io) templates for provisioning NSX-T objects
in preparation for installing Tanzu Application Service (TAS). This approach
automates the setup described in the
[installation docs](https://docs.vmware.com/en/VMware-Tanzu-Application-Service/2.13/tas-for-vms/vsphere-nsx-t.html).

These templates leverage VMware's
[NSX-T provider](https://registry.terraform.io/providers/vmware/nsxt/latest/docs)
and prefer to use the newer Policy API over the older Manager API.

## Prerequisites

These templates assume a base level of NSX-T setup already exists, including:

- the edge cluster
- the overlay transport zone
- the Tier-0 gateway

## Getting Started

### Populate Variables

Start to enter your configuration variables. Use the `terraform.tfvars.example`
file as your starting point by copying it to `terraform.tfvars` and editing it.

- `tas_ops_manager_private_ip` is from `tas_infra_cidr` as we put Ops Manager VM on the infra network;
- The following values are statically allocated from `external_snat_ip_pool_cidr`
 - `tas_infrastructure_nat_gateway_ip`
 - `tas_deployment_nat_gateway_ip`
 - `tas_services_nat_gateway_ip`
 - `tas_lb_web_virtual_server_ip_address`
 - `tas_lb_tcp_virtual_server_ip_address`
 - `tas_lb_ssh_virtual_server_ip_address`
- Allocate statically a range from `tas_orgs_external_snat_ip_subnet_start` to `tas_orgs_external_snat_ip_subnet_stop` from `external_snat_ip_pool_cidr` which are used for allocating SNAT IPs to TAS orgs

For the NSX-T coordinates it's easiest to set them in your environment, so that

- they can be reused for the "Create the required LB Objects" step
- you don't store creds in the tfvars file and commit thos by accident

```bash
# the leading space is intentional, depending on the setup of your shell it
# might exclude those commands from your shell's history
 export TF_VAR_nsxt_host='...'
 export TF_VAR_nsxt_username='...'
 export TF_VAR_nsxt_password='...'
```

### Create the required LB Objects

At the time of this writing (May 2023), the NSX-T provider does not support
creating all necessary LB objects with the NSX-T policy API. Until this support
is added, it is necessary to create these objects out of band prior to running
terraform.

```bash
curl -v -u "${TF_VAR_nsxt_username}:${TF_VAR_nsxt_password}" \
    -X PATCH \
    -H 'Content-Type: application-json' \
    -d @profiles_and_monitors.json \
    "https://${TF_VAR_nsxt_host}/policy/api/v1/infra/"
```

This will create:

- LB Application Profile `tas_lb_tcp_application_profile`
- LB Monitors:
  - HTTP monitor `tas-web-monitor`
  - HTTP monitor `tas-tcp-monitor`
  - TCP monitor `tas-ssh-monitor`

### (Optional) Create more Tier1 gateway / segment

By default this terraform create the following NSX-T resources which allow to define three networks in BOSH.

- Tier-1 gateway `tas-infra-t1` and segment `tas-infra-segment` (192.168.1.0/24)
- Tier-1 gateway `tas-deployment-t1` and segment `tas-deployment-segment` (192.168.2.0/24)
- Tier-1 gateway `tas-services-t1` and segment `tas-services-segment` (192.168.3.0/24)

Assuming you need to have one more network named `svc2`, please add the following resources.

1. In `variables.tf`, add

```bash
variable "tas_svc2_cidr" {
  description = "CIDR for the TAS services segment"
  type        = string
  default     = "192.168.4.0/24"
}

variable "tas_svc2_nat_gateway_ip" {
  description = "The source IP address to use for all traffic leaving the TAS svc2 network"
  type        = string
}
```

2. In `terraform.tfvars`, add

```bash
tas_svc2_cidr = "192.168.4.0/24"
tas_svc2_nat_gateway_ip = "12.10.10.99"  # an unused IP from `external_snat_ip_pool_cidr`
```

3. Create file `svc2-network.tf` with content as follows.

```bash
resource "nsxt_policy_tier1_gateway" "tas-svc2-t1-gw" {
  description               = "Tier-1 Gateway for TAS svc2 Network"
  display_name              = "tas-svc2-t1"
  edge_cluster_path         = data.nsxt_policy_edge_cluster.ec.path
  tier0_path                = data.nsxt_policy_tier0_gateway.nsxt_active_t0_gateway.path
  route_advertisement_types = ["TIER1_STATIC_ROUTES", "TIER1_CONNECTED", "TIER1_NAT", "TIER1_LB_VIP", "TIER1_LB_SNAT"]
  pool_allocation           = "ROUTING"

  tag {
    tag = "created_by"
    scope = "terraform"
  }
}

resource "nsxt_policy_segment" "tas-svc2-segment" {
  description         = "TAS svc2 Network Segment"
  display_name        = "tas-svc2-segment"
  connectivity_path   = nsxt_policy_tier1_gateway.tas-svc2-t1-gw.path
  transport_zone_path = data.nsxt_policy_transport_zone.overlay_tz.path

  subnet {
    # this turns "192.168.3.0/24" to "192.168.3.1/24" (uses the first host in the CIDR)
    cidr = join("/", tolist([cidrhost(var.tas_svc2_cidr, 1), split("/", var.tas_svc2_cidr)[1]]))
  }

  tag {
    tag = "created_by"
    scope = "terraform"
  }
}

resource "nsxt_policy_nat_rule" "tas-svc2-snat" {
  display_name        = "tas-svc2-snat"
  description         = "SNAT rule for all VMs in the TAS svc2 network"
  action              = "SNAT"
  gateway_path        = data.nsxt_policy_tier0_gateway.nsxt_active_t0_gateway.path
  logging             = false
  source_networks     = ["${var.tas_svc2_cidr}"]
  translated_networks = [var.tas_svc2_nat_gateway_ip]
  firewall_match      = "BYPASS"
  rule_priority       = 1000

  tag {
    tag = "created_by"
    scope = "terraform"
  }
}
```

### Run Terraform

```bash
$ terraform init
$ terraform apply
```
