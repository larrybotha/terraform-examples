resource "digitalocean_spaces_bucket" "terraform-state" {
  name   = local.space_name
  region = var.space.region
}
