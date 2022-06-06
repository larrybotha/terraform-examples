data "cloudinit_config" "config" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "terraform-cloud-init.yml"
    merge_type   = "list(append)+dict(no_replace,recurse_list)+str()"
    content_type = "text/cloud-config"
    content = templatefile("${local.templates_dir}/cloud-config.yml", {
      files        = local.files
      ssh_key      = file(var.ssh_key.public_key_file)
      goss_version = local.package_versions.goss
    })
  }
}
