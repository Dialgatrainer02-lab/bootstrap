locals {
  openbao_service_fqdn      = var.dns_domain != null && trimspace(var.dns_domain) != "" ? "openbao.${var.dns_domain}" : "openbao"
  local_mirror_service_fqdn = var.dns_domain != null && trimspace(var.dns_domain) != "" ? "local-mirror.${var.dns_domain}" : "local-mirror"

  rendered_user_data = coalesce(
    var.cloud_init_user_data,
    templatefile("${path.module}/cloud-init.yaml.tftpl", {
      hostname                                = var.name
      ssh_authorized_keys                     = local.authorized_keys
      mirror_base_url                         = var.mirror_base_url
      openbao_service_fqdn                    = local.openbao_service_fqdn
      openbao_service_ip                      = var.openbao_service_ip
      local_mirror_service_fqdn               = local.local_mirror_service_fqdn
      local_mirror_service_ip                 = var.local_mirror_service_ip
      openbao_intermediate_ca_certificate_pem = var.openbao_intermediate_ca_certificate_pem
    }),
  )
}

locals {
  authorized_keys = distinct(concat(
    var.ssh_authorized_keys,
    [trimspace(tls_private_key.local_registry_vm_ssh.public_key_openssh)],
  ))
}

resource "tls_private_key" "local_registry_vm_ssh" {
  algorithm = "ED25519"
}

resource "local_sensitive_file" "local_registry_vm_ssh_private_key" {
  filename        = "${path.root}/keys/local-registry"
  content         = tls_private_key.local_registry_vm_ssh.private_key_openssh
  file_permission = "0600"
}

data "cloudinit_config" "user_data" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = local.rendered_user_data
  }
}

resource "proxmox_virtual_environment_file" "cloud_init_user_data" {
  content_type = "snippets"
  datastore_id = var.snippets_datastore_id
  node_name    = var.node_name

  source_raw {
    file_name = "${var.name}-user-data.yaml"
    data      = data.cloudinit_config.user_data.rendered
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
  cpu_flags = var.cpu_flags
  memory_mb = var.memory_mb

  disk_size_gb        = var.disk_size_gb
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
