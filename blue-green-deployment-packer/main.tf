terraform {
  required_version = "~> 1.0.0"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.11"
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

# general
locals {
  deployment_type_map = {
    blue                = "blue"
    green               = "green"
    transition_to_green = "transition-to-green"
    transition_to_blue  = "transition-to-blue"
  }

  # if no state is provided, assume blue
  state = lookup(local.deployment_type_map, var.state, local.deployment_type_map.blue)

  environment = merge({
    IMAGE_NAME = "nginxdemos/hello"
  }, var.env)

  package_versions = ({
    goss = "v0.3.16"
  })

  certs_dir     = "${path.module}/certs"
  scripts_dir   = "${path.module}/scripts"
  templates_dir = "${path.module}/templates"
}

# resources
locals {
  name_suffix = "${var.project_name}-${var.environment}"

  tags_deployment = {
    blue  = local.deployment_type_map.blue
    green = local.deployment_type_map.green
  }

  tags_common = {
    environment = var.environment
    project     = var.project_name,
  }

  app_instances = {
    # if the state is green, we don't want any blue app_instances
    blue = local.state == local.deployment_type_map.green ? 0 : var.droplet.count
    # if the state is blue, we don't want any green app_instances
    green = local.state == local.deployment_type_map.blue ? 0 : var.droplet.count
  }

  lb_check_interval = anytrue([
    local.state == local.deployment_type_map.green,
    local.state == local.deployment_type_map.blue
  ]) ? 10 : 6
}

# cloud-init
locals {
  files = concat(
    [
      {
        filename = ".env",
        content = base64encode(join("\n", [
          for k, v in local.environment : "${k}=${v}" if v != null
        ]))
      },
      {
        filename = "docker-compose.yml",
        content  = filebase64("${local.templates_dir}/docker-compose.yml")
      },
      {
        filename = "goss.yaml",
        content = base64encode(templatefile("${local.templates_dir}/goss.yaml", {
          schemes = ["http"]
        }))
      },
    ], var.files
  )
}