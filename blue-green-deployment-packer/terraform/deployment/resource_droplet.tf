resource "digitalocean_droplet" "blue" {
  count = local.app_instances.blue

  image              = var.droplet.image
  monitoring         = true
  name               = "app-${local.name_suffix}-${count.index}"
  private_networking = true
  region             = var.droplet.region
  size               = var.droplet.size
  tags               = concat([local.tags_deployment.blue], values(local.tags_common))

  # Prevent Digitalocean from sending email for root user and password
  ssh_keys = [digitalocean_ssh_key.terraform.id]

  # Configure server with cloud-init
  user_data = data.cloudinit_config.config.rendered

  # Use a healthcheck to determine when this resource's services are available
  provisioner "local-exec" {
    command = <<-EOT
      ${local.scripts_dir}/health-check-droplet.sh ${self.ipv4_address}
      ${local.scripts_dir}/wait-for-loadbalancer.sh
    EOT
  }

  # Only destroy containers after new containers have been provisioned
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [user_data]
  }
}

resource "digitalocean_droplet" "green" {
  count = local.app_instances.green

  image              = var.droplet.image
  monitoring         = true
  name               = "app-${local.name_suffix}-${count.index}"
  private_networking = true
  region             = var.droplet.region
  size               = var.droplet.size
  tags               = concat([local.tags_deployment.green], values(local.tags_common))

  # Prevent Digitalocean from sending email for root user and password
  ssh_keys = [digitalocean_ssh_key.terraform.id]

  # Configure server with cloud-init
  user_data = data.cloudinit_config.config.rendered

  # Use a healthcheck to determine when this resource's services are available
  provisioner "local-exec" {
    command = <<-EOT
      ${local.scripts_dir}/health-check-droplet.sh ${self.ipv4_address}
      ${local.scripts_dir}/wait-for-loadbalancer.sh
    EOT
  }

  # Only destroy containers after new containers have been provisioned
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [user_data]
  }
}
