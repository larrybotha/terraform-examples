# Add the public key to Digitalocean
# This allows one to log in to droplets without specifying the private key with
# $ ssh user@remote -i my-key
resource "digitalocean_ssh_key" "terraform" {
  name       = "terraform"
  public_key = file("my-key.pub")
}
