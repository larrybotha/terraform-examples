variable "cloudfront_public_key" {
  description = "The public key for signed URLs"
  type        = string
}

variable "distribution_name" {
  description = "CDN name - used to name the CloudFront distribution and related assets"
  type        = string
}

variable "bucket_name" {
  description = "The name of the bucket associated with CloudFront"
  type        = string
}

variable "bucket_acl" {
  description = "The bucket's ACL"
  default     = "private"
  type        = string

  validation {
    condition     = index(["private", "public-read", "public-write"], var.bucket_acl) > -1
    error_message = "Invalid bucket ACL value ${var.bucket_acl}"
  }
}

variable "bucket_versioning" {
  description = "Whether to enable or disable bucket versioning"
  type        = string

  validation {
    condition     = index(["Enabled", "Disabled", "Suspended"], var.bucket_versioning) > -1
    error_message = "Invalid bucket versioning value ${var.bucket_versioning}"
  }
}

variable "tags" {
  description = "Tags to apply to AWS resources"
  type        = map(string)
  default     = {}
}

#variable "tld" {
#  description = "Top-level domain where CNAMEs will be created for certificate validation"
#}
