locals {
  rendered_user_data = coalesce(
    var.cloud_init_user_data,
    templatefile("${path.module}/cloud-init.yaml.tftpl", {
      hostname            = var.name
      ssh_authorized_keys = local.authorized_keys
      drive_path          = "/dev/sdb"
    }),
  )
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

  filename        = "${path.root}/keys/local-repo"
  content         = tls_private_key.local_repo_vm_ssh.private_key_openssh
  file_permission = "0600"
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
  source = "../vm"

  name         = var.name
  node_name    = var.node_name
  datastore_id = var.datastore_id
  pool_id      = var.pool_id

  vm_id     = var.vm_id
  cpu_cores = var.cpu_cores
  cpu_type  = var.cpu_type
  memory_mb = var.memory_mb

  disk_size_gb    = var.disk_size_gb
  extra_disks = [
    {
      size_gb   = var.packages_disk_size_gb
      interface = "scsi1"
    }
  ]
  network_bridge  = var.network_bridge
  ipv4_address    = var.ipv4_address
  ipv4_gateway    = var.ipv4_gateway
  dns_servers     = var.dns_servers
  dns_domain      = var.dns_domain
  tags            = var.tags
  boot_image_id   = var.boot_image_id
  boot_image_kind = var.boot_image_kind

  cloud_init_user_data_file_id = proxmox_virtual_environment_file.cloud_init_user_data.id
}
