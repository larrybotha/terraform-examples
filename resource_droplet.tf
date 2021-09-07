resource "digitalocean_droplet" "terraform" {
  count     = 1
  image     = "ubuntu-20-04-x64"
  name      = "terraform"
  region    = "lon1"
  size      = "s-1vcpu-1gb"
  user_data = file("user_data.yml")
}
