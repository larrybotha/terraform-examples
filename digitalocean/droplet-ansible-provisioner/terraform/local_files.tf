resource "local_file" "ansible_hosts" {
  content = templatefile("${path.module}/templates/ansible-hosts.ini.tpl", {
    ips      = digitalocean_droplet.scratch[*].ipv4_address
    ssh_user = var.ssh_user
  })
  filename = "../ansible/inventory/hosts.ini"
}
