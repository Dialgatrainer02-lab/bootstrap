locals {
  base_cloud_init_fragment = templatefile("${path.module}/../shared/cloudinit/fragments/base.yaml.tftpl", {
    hostname            = var.name
    package_update      = true
    package_upgrade     = false
    ssh_authorized_keys = local.authorized_keys
  })
  service_cloud_init_fragment = templatefile("${path.module}/cloud-init.yaml.tftpl", {
    virtiofs_mapping_name   = local.virtiofs_mapping_name
    repos_archive_file_name = var.repos_archive_file_name
  })
  rendered_user_data = coalesce(var.cloud_init_user_data, try(data.cloudinit_config.user_data[0].rendered, null))

  virtiofs_enabled      = var.virtiofs != null || var.virtiofs_dir_mapping_name != null || var.virtiofs_dir_mapping_path != null
  virtiofs_mapping_name = coalesce(try(var.virtiofs.mapping, null), var.virtiofs_dir_mapping_name, "${var.name}-virtiofs")
  virtiofs_mapping_path = coalesce(var.virtiofs_dir_mapping_path, "/mnt/pve/${local.virtiofs_mapping_name}")
  virtiofs_direct_io    = coalesce(try(var.virtiofs.direct_io, null), false)
  virtiofs_expose_xattr = coalesce(try(var.virtiofs.expose_xattr, null), true)
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

  lifecycle {
    precondition {
      condition     = local.virtiofs_enabled
      error_message = "local_mirror requires virtiofs to be enabled so the prebuilt archive can be mounted and served."
    }
  }
}

resource "proxmox_virtual_environment_file" "repos_archive" {
  content_type = "snippets"
  datastore_id = var.artifacts_datastore_id
  node_name    = var.node_name

  source_file {
    path      = var.repos_archive_source_path
    file_name = var.repos_archive_file_name
  }
}

module "virtiofs_dir_mapping" {
  count = local.virtiofs_enabled ? 1 : 0

  source = "../infrastructure/hardware_mapping_dir"

  name    = local.virtiofs_mapping_name
  comment = var.virtiofs_dir_mapping_comment
  map = [
    {
      node = var.node_name
      path = local.virtiofs_mapping_path
    }
  ]
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
  virtiofs = local.virtiofs_enabled ? {
    mapping      = module.virtiofs_dir_mapping[0].name
    cache        = try(var.virtiofs.cache, null)
    direct_io    = local.virtiofs_direct_io
    expose_acl   = try(var.virtiofs.expose_acl, null)
    expose_xattr = local.virtiofs_expose_xattr
  } : null
  extra_disks         = []
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

  depends_on = [proxmox_virtual_environment_file.repos_archive]
}
