provider "aws" {
  alias   = "first"
  region  = var.region_1

  default_tags {
    tags = var.tags_1
  }
  assume_role {
    role_arn     = var.assume_role_arn
    session_name = var.role_session_name
  }
}

provider "aws" {
  alias   = "second"
  region  = var.region_2

  default_tags {
    tags = var.tags_2
  }
  assume_role {
    role_arn     = var.assume_role_arn
    session_name = var.role_session_name
  }
}
