# render the IP addresses once the plan is applied
output "ip_address" {
  value       = digitalocean_droplet.scratch[*].ipv4_address
  description = "Public IPs of droplets"
}
