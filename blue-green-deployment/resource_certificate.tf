resource "digitalocean_certificate" "loadbalancer" {
  name             = "lb-cert-${local.name_suffix}"
  type             = "custom"
  private_key      = file("${local.certs_dir}/lb.key")
  leaf_certificate = file("${local.certs_dir}/lb.crt")

  lifecycle {
    create_before_destroy = true
  }
}
