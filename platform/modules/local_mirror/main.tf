locals {
  base_cloud_init_fragment = templatefile("${path.module}/../shared/cloudinit/fragments/base.yaml.tftpl", {
    hostname            = var.name
    package_update      = true
    package_upgrade     = false
    ssh_authorized_keys = local.authorized_keys
  })
  service_cloud_init_fragment = templatefile("${path.module}/cloud-init.yaml.tftpl", {
    repo_disk_device  = var.repo_disk_device
    repo_disk_size_gb = var.packages_disk_size_gb
  })
  rendered_user_data = coalesce(var.cloud_init_user_data, try(data.cloudinit_config.user_data[0].rendered, null))
}

locals {
  authorized_keys = distinct(concat(
    var.ssh_authorized_keys,
    [trimspace(tls_private_key.local_repo_vm_ssh.public_key_openssh)],
  ))
}

resource "tls_private_key" "local_repo_vm_ssh" {

  algorithm = "ED25519"
}

resource "local_sensitive_file" "local_repo_vm_ssh_private_key" {

  filename        = "${path.root}/keys/local-mirror"
  content         = tls_private_key.local_repo_vm_ssh.private_key_openssh
  file_permission = "0600"
}

data "cloudinit_config" "user_data" {
  count = var.cloud_init_user_data == null ? 1 : 0

  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = local.base_cloud_init_fragment
  }

  part {
    content_type = "text/cloud-config"
    content      = local.service_cloud_init_fragment
  }
}

resource "proxmox_virtual_environment_file" "cloud_init_user_data" {
  content_type = "snippets"
  datastore_id = var.snippets_datastore_id
  node_name    = var.node_name

  source_raw {
    file_name = "${var.name}-user-data.yaml"
    data      = local.rendered_user_data
  }
}

module "vm" {
  source = "../infrastructure/vm"

  name         = var.name
  node_name    = var.node_name
  datastore_id = var.datastore_id
  pool_id      = var.pool_id

  vm_id     = var.vm_id
  cpu_cores = var.cpu_cores
  cpu_type  = var.cpu_type
  cpu_flags = var.cpu_flags
  memory_mb = var.memory_mb

  disk_size_gb = var.disk_size_gb
  extra_disks = [
    {
      size_gb   = var.packages_disk_size_gb
      interface = "scsi1"
    }
  ]
  network_bridge      = var.network_bridge
  ipv4_address        = var.ipv4_address
  ipv4_gateway        = var.ipv4_gateway
  dns_servers         = var.dns_servers
  dns_domain          = var.dns_domain
  tags                = var.tags
  boot_image_id       = var.boot_image_id
  boot_image_kind     = var.boot_image_kind
  ssh_authorized_keys = null

  cloud_init_user_data_file_id = proxmox_virtual_environment_file.cloud_init_user_data.id
}
