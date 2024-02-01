provider "aws" {
  region     = var.region
  default_tags {
    tags = var.tags
  }
  assume_role {
    role_arn     = var.assume_role_arn
    session_name = var.role_session_name
  }
}

# the provider to read the ASM secrets which are located in the the region of platform automation
provider "aws" {
  alias      = "plat-auto"
  region     = var.plat_auto_region
  assume_role {
    role_arn     = var.assume_role_arn
    session_name = var.role_session_name
  }
}
