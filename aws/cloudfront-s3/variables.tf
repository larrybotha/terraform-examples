variable "access_key" {
  type = string

  validation {
    condition     = length(var.access_key) > 0
    error_message = "AWS access key is required"
  }
  sensitive = true
}

variable "secret_key" {
  type = string

  validation {
    condition     = length(var.secret_key) > 0
    error_message = "AWS secret key is required"
  }
  sensitive = true
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "distribution_name" {
  description = "CDN name - used to name the CloudFront distribution and related assets"
  type        = string
}

variable "bucket_name" {
  type    = string
  default = "tmp-bucket-foo"
}

variable "bucket_versioning" {
  description = "Whether to enable or disable bucket versioning"
  default     = "Disabled"
  type        = string

  validation {
    condition     = index(["Enabled", "Disabled", "Suspended"], var.bucket_versioning) > -1
    error_message = "Invalid bucket versioning value ${var.bucket_versioning}"
  }
}

variable "cloudfront_public_key" {
  description = "The base64 encoded public key required for signed URLs"
  type        = string
}
