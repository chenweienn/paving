terraform {
    required_providers {
      nsxt = {
          source = "vmware/nsxt"
          version = "~> 3.3.0"
      }
    }

    required_version = ">=1.0.0"
}
