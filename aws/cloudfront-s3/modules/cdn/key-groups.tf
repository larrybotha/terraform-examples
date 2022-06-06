resource "aws_cloudfront_key_group" "cf_keygroup" {
  items = [aws_cloudfront_key_group]
  name  = "${random_id.id.hex}-group"
}
