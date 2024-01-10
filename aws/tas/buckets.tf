resource "aws_s3_bucket" "bosh-bucket" {
  bucket = "${var.environment_name}-bosh-bucket"
}

resource "aws_s3_bucket_versioning" "bosh-bucket" {
  bucket = aws_s3_bucket.bosh-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_kms_key" "s3-encryption-key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_kms_alias" "s3-encryption-key-alias" {
  name          = "alias/${var.environment_name}-s3-encryption"
  target_key_id = aws_kms_key.s3-encryption-key.key_id
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bosh-bucket-encryption" {
  bucket = aws_s3_bucket.bosh-bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3-encryption-key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

locals {
  tas_buckets = toset([
    "buildpacks",
    "packages",
    "resources",
    "droplets"
  ])
}


resource "aws_s3_bucket" "buckets" {
  for_each = local.tas_buckets

  bucket = "${var.environment_name}-${each.key}-bucket"
}

resource "aws_s3_bucket_versioning" "buckets_versioning" {
  for_each = local.tas_buckets

  bucket = aws_s3_bucket.buckets[each.key].id
  versioning_configuration {
    status = "Enabled"
  }
}

# use the key defined in ops-manager-buckets.tf
resource "aws_s3_bucket_server_side_encryption_configuration" "buckets-encryption" {
  for_each = local.tas_buckets

  bucket = aws_s3_bucket.buckets[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3-encryption-key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

