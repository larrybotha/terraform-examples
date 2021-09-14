variable "project_name" {
  default     = "terraform-example"
  description = "The project name"
  type        = string
}

variable "environment" {
  default     = "staging"
  description = "The project environment"
  type        = string
}

variable "do_access_token" {
  description = "Digitalocean personal access token"
  type        = string

  validation {
    condition     = length(var.do_access_token) > 0
    error_message = "A Digitalocean access token is required."
  }
}

variable "do_spaces_access_id" {
  description = "Digitalocean spaces access ID"
  type        = string

  validation {
    condition     = length(var.do_spaces_access_id) > 0
    error_message = "A Digitalocean spaces access ID is required."
  }
}

variable "do_spaces_secret_key" {
  description = "Digitalocean spaces secret key"
  type        = string

  validation {
    condition     = length(var.do_spaces_secret_key) > 0
    error_message = "A Digitalocean spaces secret key is required."
  }
}

variable "space" {
  default = {
    region = "fra1"
    name   = "terraform-example-1"
  }
  type = object({
    region = string
    name   = string
  })
}
