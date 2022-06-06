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

variable "bucket_name" {
  type    = string
  default = "tmp-bucket-foo"
}
