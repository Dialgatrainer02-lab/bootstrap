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
write_files:
  - path: /etc/ssh/trusted-user-ca-keys.pem
    permissions: "0644"
    content: |
      ${tls_private_key.ssh_ca.public_key_openssh}
  - path: /etc/ssh/sshd_config.d/99-trusted-user-ca.conf
    permissions: "0644"
    content: |
      TrustedUserCAKeys /etc/ssh/trusted-user-ca-keys.pem
runcmd:
  - systemctl reload sshd
package_upgrade: true
CLOUDINIT

}


resource "proxmox_virtual_environment_storage_directory" "cloud_config_store" {
  id    = "cloud-config-store"
  path  = "/var/lib/cloud-config-store"
  nodes = toset(data.proxmox_virtual_environment_nodes.available_nodes.names)

  content = ["snippets"]
  shared  = true
  disable = false
}
