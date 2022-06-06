locals {
  origin_s3_id = module.bucket.id
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = module.bucket.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      # TODO: create OAI
      origin_access_identity = "origin-access-identity/cloudfront/ABCDEFG1234567"
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0     # min time for objects to live in the distribution cache
    default_ttl = 3600  # default time for objects to live in the distribution cache
    max_ttl     = 86400 # max time for objects to live in the distribution cache
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cloudfront_cdn.arn
  }

  tags = var.tags

  depends_on = [aws_acm_certificate.cloudfront_cdn]
}
