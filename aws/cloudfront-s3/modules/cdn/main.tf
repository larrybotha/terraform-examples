locals {
  origin_id = aws_s3_bucket.bucket.id
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  enabled         = true
  is_ipv6_enabled = true

  origin {
    domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_id   = local.origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.bucket.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.origin_id
    viewer_protocol_policy = "https-only"
    compress               = true

    forwarded_values {
      query_string = false

      cookies { forward = "none" }
    }

    min_ttl     = 0     # min time for objects to live in the distribution cache
    default_ttl = 3600  # default time for objects to live in the distribution cache
    max_ttl     = 86400 # max time for objects to live in the distribution cache

    # Require signed URLs for all requests
    trusted_key_groups = [
      aws_cloudfront_key_group.cdn.id
    ]
  }

  viewer_certificate {
    # TODO: use acm_certificate_arn = aws_acm_certificate.cdn.arn for custom domain
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = var.tags

  # wait for distribution to be live before continuing / completing provisioning
  wait_for_deployment = true

  depends_on = [
    # TODO: enable when using aws_acm_certificate
    #aws_acm_certificate.cloudfront_cdn
  ]
}
