terraform {
  required_version = "~> 1.0.0"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.11"
    }
  }

  # Values specific to your backend should be defined in a tfvars file, and
  # Terraform should be explicitly initialised with that file. e.g.:
  #
  # $ cp backend.gitignore.tfvars{.example,}
  # $ terraform init -backend-config=backend.gitignore.tfvars
  backend "s3" {
    skip_region_validation      = true
    skip_credentials_validation = true
    # Due to the above flags, this value is not used, but it is still a
    # required field.  It should be set to be a valid S3 region
    region = "us-east-1"
  }
}
