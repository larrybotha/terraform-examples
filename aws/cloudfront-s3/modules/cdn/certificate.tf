provider "aws" {
  alias  = "us_east"
  region = "us-east-1"
}

resource "aws_acm_certificate" "cloudfront_cdn" {
  provider = aws.us_east

  domain_name       = "*.cdn.${var.domain_name}"
  validation_method = "DNS"

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "digitalocean_record" "aws_certificate_validation_cname" {
  for_each = toset(aws_acm_certificate.cloudfront_cdn.domain_validation_options)
  name     = each.resource_record_name
  type     = each.resource_record_type
  value    = each.resource_record_value
  domain   = var.dns_apex_domain
  ttl      = 3600
}
