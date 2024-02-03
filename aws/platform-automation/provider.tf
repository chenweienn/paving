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
