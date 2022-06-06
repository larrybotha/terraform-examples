resource "digitalocean_loadbalancer" "lb" {
  count = var.loadbalancer.count

  name                   = "${local.name_suffix}-${count.index}"
  region                 = var.loadbalancer.region
  redirect_http_to_https = var.loadbalancer.force_ssl

  forwarding_rule {
    entry_port     = 443
    entry_protocol = "https"

    target_port     = 80
    target_protocol = "http"

    certificate_name = digitalocean_certificate.loadbalancer.name
  }

  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"

    target_port     = 80
    target_protocol = "http"
  }

  healthcheck {
    # Send requests to the goss server running in the droplet
    protocol               = "http"
    path                   = "/healthz"
    port                   = 8080
    check_interval_seconds = local.loadbalancer_check_interval
  }

  droplet_tag = local.tags_common.project
}
