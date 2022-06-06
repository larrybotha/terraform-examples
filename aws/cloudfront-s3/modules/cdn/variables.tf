variable "cf_private_key_name" {
  description = "The name of the SSM parameter for the CloudFront trusted key group"
  type        = string
}

variable "cf_public_key_name" {
  description = "The name of the SSM parameter for the CloudFront trusted key group"
  type        = string
}

variable "tags" {
  description = "Tags to apply to AWS resources"
  type        = map(string)
  default     = {}
}

variable "tld" {
  description = "Top-level domain where CNAMEs will be created for certificate validation"
}
