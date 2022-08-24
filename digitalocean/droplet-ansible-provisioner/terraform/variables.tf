variable "do_access_token" {
  type = string

  validation {
    condition     = length(var.do_access_token) > 0
    error_message = "Digitalocean access token is required"
  }
}

variable "user_data" {
  default = "user_data.yml"
}

variable "ssh_user" {
  type    = string
  default = "app"
}

variable "ssh_key" {
  type = object({
    name            = string
    public_key_file = string
  })
  default = {
    name            = "terraform-ansible-scratch"
    public_key_file = "../my-key.pub"
  }
}

variable "droplet" {
  type = object({
    name   = string
    count  = number
    image  = string
    region = string
    size   = string
  })
  default = {
    name   = "terraform-ansible-scratch"
    count  = 2
    image  = "ubuntu-20-04-x64"
    region = "lon1"
    size   = "s-1vcpu-1gb"
  }
}
