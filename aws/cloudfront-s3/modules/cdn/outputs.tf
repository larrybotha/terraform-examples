output "bucket_id" {
  description = "ID of the bucket"
  value       = aws_s3_bucket.bucket.id
}

output "cloudfront_domain" {
  description = "CloudFront domain name"
  value       = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "cloudfront_public_key_id" {
  description = "ID of CloudFront public key id"
  value       = aws_cloudfront_public_key.cdn.id
}
