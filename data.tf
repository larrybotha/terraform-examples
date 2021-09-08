data "cloudinit_config" "config" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "my-cloud-init.yml"
    merge_type   = "list(append)+dict(no_replace,recurse_list)+str()"
    content_type = "text/cloud-config"
    content = templatefile(var.user_data, {
      ssh_key = file(var.ssh_key.public_key_file)
    })
  }
}
