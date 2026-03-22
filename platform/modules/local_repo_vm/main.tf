locals {
  rendered_user_data = coalesce(
    var.cloud_init_user_data,
    templatefile("${path.module}/cloud-init.yaml.tftpl", {
      hostname                      = var.name
    }),
  )
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

  vm_id     = var.vm_id
  cpu_cores = var.cpu_cores
  cpu_type  = var.cpu_type
  memory_mb = var.memory_mb

  disk_size_gb    = var.disk_size_gb
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
