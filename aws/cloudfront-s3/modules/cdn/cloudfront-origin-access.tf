resource "aws_cloudfront_origin_access_identity" "bucket" {
  comment = "bucket.oai.${aws_s3_bucket.bucket.bucket_regional_domain_name}"
}

data "aws_iam_policy_document" "read_write_bucket" {
  statement {
    effect    = "Allow"
    actions   = ["s3:*Object"]
    resources = ["${aws_s3_bucket.bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.bucket.iam_arn]
    }
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.bucket.arn]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.bucket.iam_arn]
    }
  }
}
