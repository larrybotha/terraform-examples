# create 2 droplets
resource "digitalocean_droplet" "docean-terraform-example" {
  count     = 2
  image     = "ubuntu-20-04-x64"
  name      = "docean-terraform-example"
  region    = "lon1"
  size      = "s-1vcpu-1gb"
  user_data = file("user_data.yml")
}
