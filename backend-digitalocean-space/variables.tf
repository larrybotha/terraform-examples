variable "project_name" {
  description = "The project name"
  type        = string
  default     = "terraform-example"
}

variable "environment" {
  description = "The project environment"
  type        = string
  default     = "staging"
}

variable "do_access_token" {
  description = "Digitalocean personal access token"

  validation {
    condition     = length(var.do_access_token) > 0
    error_message = "A Digitalocean access token is required."
  }
}
