# ED25519 key
resource "tls_private_key" "ssh_ca" {
  algorithm = "ED25519"
}

locals {
  base_user_data_file = <<-CLOUDINIT
#cloud-config

package_update: false
package_upgrade: false
hostname: cloud-config-test

users:
      - name: olivia
        groups:
          - sudo
        shell: /bin/bash
        password: test
        sudo: ALL=(ALL) NOPASSWD:ALL

CLOUDINIT

}

locals {
  cloud-config-store = "cloud-config-store"
}

resource "proxmox_virtual_environment_storage_directory" "cloud-config-store" {
  id    = local.cloud-config-store
  path  = "/var/lib/snippets/cloud-config-store"
  nodes = toset(data.proxmox_virtual_environment_nodes.available_nodes.names)

  content = ["snippets"]
  shared  = true
  disable = false
}
