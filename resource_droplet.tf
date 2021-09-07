resource "digitalocean_droplet" "terraform" {
  count     = var.droplet.count
  image     = var.droplet.image
  name      = var.droplet.name
  region    = var.droplet.region
  size      = var.droplet.size
  user_data = file(var.droplet.user_data_file)
}
