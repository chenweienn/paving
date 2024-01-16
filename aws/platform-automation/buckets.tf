# the bucket concumed as BOSH director blobstore
resource "aws_s3_bucket" "bosh-bucket" {
  bucket_prefix = "${var.environment_name}-bosh-bucket-"
}

# the bucket consumed by platform automation pipelines to cache Tanzu Network (pivnet) resources
resource "aws_s3_bucket" "pivnet-bucket" {
  bucket_prefix = "${var.environment_name}-pivnet-bucket-"
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


