resource "random_id" "key_group" {
  byte_length = 8
}

resource "aws_cloudfront_public_key" "cdn" {
  name        = replace("${var.distribution_name}-${random_id.key_group.hex}", ".", "-")
  encoded_key = var.cloudfront_public_key

  lifecycle { create_before_destroy = true }
}

resource "aws_cloudfront_key_group" "cdn" {
  items = [aws_cloudfront_public_key.cdn.id]
  name  = "${aws_cloudfront_public_key.cdn.name}-group"

  lifecycle { create_before_destroy = true }
}
