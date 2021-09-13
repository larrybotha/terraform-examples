packer {
  required_plugins {
    digitalocean = {
      version = "~> 1.0.0"
      source = "github.com/hashicorp/digitalocean"
    }
  }
}

locals {
  image = "docker-20-04"
  project_name = length(var.project_name) > 0 ? var.project_name : "terraform-packer-example"
  image_name = local.project_name
  region = "lon1"
  size = "512mb"
  ssh_username = "root"
}

variable "do_access_token" {
  description = "Digitalocean access token"
}

variable "do_spaces_key" {
  description = "Digitalocean access token"
}

variable "do_spaces_key" {
  description = "Digitalocean spaces key"
}

variable "do_spaces_secret" {
  description = "Digitalocean spaces secret"
}

variable "do_space_name" {
  description = "Digitalocean space name"
}

variable "image_suffix" {
  description = "Suffix to be added to built image"
  validations = {
    condition = length(var.image_prefix) > 0
    error_message = "Image suffix is required"
  }
}

variable "project_name" {
  description = "The name of the project. Used when creating images"
}

source "digitalocean" "base-image" {
  api_token = var.do_access_token
  image = local.image
  region = local.region
  size = local.size
  ssh_username = local.ssh_username
}

post-process "digitalocean-import" {
  api_token = var.do_access_token
  spaces_key = var.do_spaces_key
  spaces_secret = var.do_spaces_secret
  space_name = var.do_space_name
  image_name = "${local.image_name}-${local.image_suffix}"
  tags = [local.image_suffix]
}

build {
  sources = ["source.digitalocean.base-image"]
}
