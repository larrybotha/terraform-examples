terraform {
  required_version = "~> 1.0.0"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.11"
    }
  }

  backend "s3" {}
}

# resources
locals {
  space_name = var.project_name
}
