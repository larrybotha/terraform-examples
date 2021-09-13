variable "state" {
  description = "Current deployment state"
  default     = "blue"
}

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

variable "resource_tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default     = {}
}

variable "ssh_key" {
  type = object({
    public_key_file  = string
    private_key_file = string
  })
  default = {
    public_key_file  = "my-key.pub"
    private_key_file = "my-key"
  }
}

variable "droplet" {
  type = object({
    count  = number
    image  = string
    region = string
    size   = string
  })
  default = {
    count  = 1
    image  = "docker-20-04"
    region = "lon1"
    size   = "s-1vcpu-1gb"
  }
}

variable "loadbalancer" {
  type = object({
    count     = number
    region    = string
    force_ssl = bool
  })
  default = {
    count     = 1
    region    = "lon1"
    force_ssl = true
  }
}

variable "files" {
  description = "User files to be copied to the application's working directory (`/var/app`). The file's content must be provided to Terraform as a base64 encoded string."
  type        = list(object({ filename : string, content : string }))
  default     = []
}

variable "env" {
  description = "List of environment variables (KEY=VAL) to be made available within the application container and also Docker Compose (useful for overriding configuration options)."
  type        = map(string)
  default     = {}
}
