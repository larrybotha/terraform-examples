# render the IP addresses once the plan is applied
output "ip_address" {
  value = concat(
    digitalocean_droplet.blue[*].ipv4_address,
    digitalocean_droplet.green[*].ipv4_address,
  )
  description = "Public IPs of droplets"
}

output "ips_blue" {
  description = "IPs of blue instances"
  value       = digitalocean_droplet.blue[*].ipv4_address
}

output "ips_green" {
  description = "IPs of green instances"
  value       = digitalocean_droplet.green[*].ipv4_address
}

output "loadbalancer_healthcheck" {
  value = digitalocean_loadbalancer.lb[*].healthcheck
}

output "loadbalancer_ids" {
  value = digitalocean_loadbalancer.lb[*].id
}

output "state" {
  value = local.state
}

# preview the generated cloud-init config
#output "cloud-config" {
#value = "\n${data.cloudinit_config.config.rendered}"
#}
