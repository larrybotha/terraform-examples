variable "name" {
  description = "Name of the S3 bucket. Must be unique"
  type        = string

  validation {
    condition     = length(var.name) > 0
    error_message = "A bucket name is required"
  }
}

variable "acl" {
  description = "The bucket's ACL"
  default     = "private"
  type        = string

  validation {
    condition     = index(["private", "public-read", "public-write"], var.acl) > -1
    error_message = "Invalid ACL value ${var.acl}"
  }
}

variable "tags" {
  description = "Tags to apply to the bucket"
  type        = map(string)
  default     = {}
}
