resource "digitalocean_droplet" "scratch" {
  count  = var.droplet.count
  image  = var.droplet.image
  name   = "${var.droplet.name}.${count.index}"
  region = var.droplet.region
  size   = var.droplet.size

  # Prevent Digitalocean from sending email for root user and password
  ssh_keys = [digitalocean_ssh_key.terraform.id]

  user_data = data.cloudinit_config.config.rendered
}
