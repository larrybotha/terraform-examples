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
    protocol = "http"
    path     = "/healthz"
    port     = 8080

    # This interval determines how long it will take Digitalocean to route
    # traffic to a healthy droplet.
    #
    # Once a droplet responds with 5 successive health checks, the load balancer
    # will begin routing traffic to it
    #
    # i.e. with the Digitalocean defaults a healthy droplet added to a load
    # balancer will wait the following amount of time before any requests are
    # sent to it:
    # 10s * 5 = 50s
    #
    # NB: for some reason we get 500 errors when updating a load balancer under
    # the following conditions in a single `terraform apply`:
    #   - creating new droplets
    #   - updating a load balancer
    #   - load balancer uses droplet_tag
    #
    # As a result of this, we can't set check_interval_seconds dynamically based
    # on the deployment type (.e.g shorter interval when transitioning between
    # blue and green, slower interval when we are in blue / green)
    #check_interval_seconds = local.lb_check_interval
    check_interval_seconds = 3
  }

  droplet_tag = local.tags_common.project
}
