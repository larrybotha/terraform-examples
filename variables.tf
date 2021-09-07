variable "ssh_key" {
  type = object({
    name            = string
    public_key_file = string
  })
  default = {
    name            = "terraform-example"
    public_key_file = "my-key.pub"
  }
}

variable "droplet" {
  type = object({
    name           = string
    count          = number
    image          = string
    region         = string
    size           = string
    user_data_file = string
  })
  default = {
    name           = "terraform-example"
    count          = 2
    image          = "ubuntu-20-04-x64"
    region         = "lon1"
    size           = "s-1vcpu-1gb"
    user_data_file = "user_data.yml"
  }
}
