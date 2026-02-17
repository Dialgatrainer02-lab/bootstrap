# ED25519 key
resource "tls_private_key" "ssh_ca" {
  algorithm = "ED25519"
}

locals {
  base_user_data_file = <<-CLOUDINIT
#cloud-config
hostname: testing
manage_etc_hosts: true
fqdn: testing
password: changeme 
chpasswd:
  expire: False
users:
  - default
runcmd:
  - touch /tmp/cloud-init-run
package_upgrade: true
CLOUDINIT

}


resource "proxmox_virtual_environment_storage_directory" "cloud-config-store" {
  id    = "cloud-config-store"
  path  = "/var/lib/snippets/cloud-config-store"
  nodes = toset(data.proxmox_virtual_environment_nodes.available_nodes.names)

  content = ["snippets"]
  shared  = true
  disable = false
}
