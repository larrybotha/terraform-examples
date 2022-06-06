# Add the public key to Digitalocean
# This allows one to log in to droplets without specifying the private key with
# $ ssh user@remote -i my-key
resource "digitalocean_ssh_key" "terraform" {
  name       = "ssh-key-${local.name_suffix}"
  public_key = file(var.ssh_key.public_key_file)
}
