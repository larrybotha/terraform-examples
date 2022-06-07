output "bucket" {
  value       = module.cdn.bucket_id
  description = "Bucket"
}

output "cloudfront_domain" {
  description = "CloudFront domain name"
  value       = module.cdn.cloudfront_domain
}

output "cloudfront_trusted_key_group_name" {
  description = "ID of CloudFront trusted key group"
  value       = module.cdn.cloudfront_public_key_id
}
