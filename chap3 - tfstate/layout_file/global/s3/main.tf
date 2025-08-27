provider "aws" {
  region = "eu-north-1"
}

#création du S3 bucket
resource "aws_s3_bucket" "Mask_bucket_s3" {
  bucket = "mask-s3-bucket-tf"
  force_destroy = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "enabled_status" {
  bucket = aws_s3_bucket.Mask_bucket_s3.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_s3_sever" {
  bucket = aws_s3_bucket.Mask_bucket_s3.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.Mask_bucket_s3.id

  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
  
}

resource "aws_dynamodb_table" "dynamobd_lock" {
  name = "bucket_s3_db_lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
  
}