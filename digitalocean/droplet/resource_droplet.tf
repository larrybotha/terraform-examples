resource "digitalocean_droplet" "terraform" {
  count  = var.droplet.count
  image  = var.droplet.image
  name   = "${var.droplet.name}.${count.index}"
  region = var.droplet.region
  size   = var.droplet.size

  user_data = data.cloudinit_config.config.rendered
}
