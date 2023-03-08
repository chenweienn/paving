resource "nsxt_policy_group" "tas_gorouter" {
  display_name = "tas-gorouter"
  description  = "TAS gorouter VMs"

  tag {
    tag = "created_by"
    scope = "terraform"
  }
}

resource "nsxt_policy_group" "tas_tcp_router" {
  display_name = "tas-tcp-router"
  description  = "TAS TCP router VMs"

  tag {
    tag = "created_by"
    scope = "terraform"
  }
}

resource "nsxt_policy_group" "tas_diego_brain" {
  display_name = "tas-diego-brain"
  description  = "TAS diego brain VMs"

  tag {
    tag = "created_by"
    scope = "terraform"
  }
}
