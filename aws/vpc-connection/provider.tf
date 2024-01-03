provider "aws" {
  alias   = "first"
  region  = var.region_1

  default_tags {
    tags = var.tags_1
  }
}

provider "aws" {
  alias   = "second"
  region  = var.region_2

  default_tags {
    tags = var.tags_2
  }
}
