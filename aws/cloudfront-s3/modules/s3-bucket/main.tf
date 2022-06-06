resource "aws_s3_bucket" "bucket" {
  bucket = var.name
  tags   = var.tags

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = var.acl
}
