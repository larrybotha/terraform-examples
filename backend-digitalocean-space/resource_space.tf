resource "digitalocean_spaces_bucket" "terraform-state" {
  name   = var.space.name
  region = var.space.region

  versioning {
    enabled = true
  }

  # Destroy the bucket, even if it contains objects
  force_destroy = true
}
