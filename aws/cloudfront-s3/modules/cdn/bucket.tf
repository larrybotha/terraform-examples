resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  tags   = var.tags

  force_destroy = true

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_policy" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.read_write_bucket.json
}

resource "aws_s3_bucket_public_access_block" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  versioning_configuration {
    status = var.bucket_versioning
  }
}
