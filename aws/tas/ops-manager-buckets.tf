resource "aws_s3_bucket" "ops-manager-bucket" {
  bucket = "${var.environment_name}-ops-manager-bucket"
}

resource "aws_s3_bucket_versioning" "ops-manager-bucket" {
  bucket = aws_s3_bucket.ops-manager-bucket.id
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

resource "aws_s3_bucket_server_side_encryption_configuration" "ops-manager-bucket-encryption" {
  bucket = aws_s3_bucket.ops-manager-bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3-encryption-key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
