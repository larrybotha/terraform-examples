terraform {
  required_version = "~> 1.0.0"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }

  #backend "s3" {
  #bucket                      = "bucket-name"
  #endpoint                    = "https://xxx.digitaloceanspaces.com"
  #key                         = "path/to/terraform.tfstate"
  #region                      = "valid-aws-region"
  #access_key                  = "access_key"
  #secret_key                  = "secret_key"
  #skip_requesting_account_id  = true
  #skip_credentials_validation = true
  #skip_get_ec2_platforms      = true
  #skip_metadata_api_check     = true
  #}
}
