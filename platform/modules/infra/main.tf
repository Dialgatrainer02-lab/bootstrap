
# Auto-discover available Proxmox nodes for downstream modules.
data "proxmox_virtual_environment_nodes" "discovered" {}

# Boilerplate module for Proxmox + Talos + Cloud-Init.
# Add resources here once you define your node schema.

# Example layout guidance:
# - Proxmox VM resources (bpg/proxmox)
# - cloud-init user-data templates (hashicorp/cloudinit)
# - Talos machine config + apply steps (siderolabs/talos)

locals {
  default_snippets_datastore_name = "${var.cluster_name}-snippets"
  default_snippets_datastore_path = "/var/lib/${var.cluster_name}-snippets"

  default_images_datastore_name = "${var.cluster_name}-images"
  default_images_datastore_path = "/var/lib/${var.cluster_name}-images"

  snippets_datastore_name = coalesce(var.snippets_datastore_name, local.default_snippets_datastore_name)
  snippets_datastore_path = coalesce(var.snippets_datastore_path, local.default_snippets_datastore_path)

  images_datastore_name = coalesce(var.images_datastore_name, local.default_images_datastore_name)
  images_datastore_path = coalesce(var.images_datastore_path, local.default_images_datastore_path)
  resource_pool_name    = coalesce(var.resource_pool_name, "${var.cluster_name}-pool")

  primary_node_name = data.proxmox_virtual_environment_nodes.discovered.names[0]
}

module "snippets" {
  source = "../datastore"

  name    = local.snippets_datastore_name
  path    = local.snippets_datastore_path
  pool_id = try(proxmox_virtual_environment_pool.platform[0].pool_id, null)
  content = ["snippets"]
}

module "images" {
  source = "../datastore"

  name    = local.images_datastore_name
  path    = local.images_datastore_path
  content = ["iso", "images", "vztmpl"]
  pool_id = try(proxmox_virtual_environment_pool.platform[0].pool_id, null)
}

resource "proxmox_virtual_environment_download_file" "vm_template" {
  node_name           = local.primary_node_name
  datastore_id        = module.images.id
  content_type        = var.vm_template_content_type
  url                 = var.vm_template_url
  file_name           = var.vm_template_file_name
  overwrite           = var.vm_template_overwrite
  overwrite_unmanaged = var.vm_template_overwrite_unmanaged
}

resource "proxmox_virtual_environment_pool" "platform" {
  count = local.resource_pool_name != null ? 1 : 0

  pool_id = local.resource_pool_name
  comment = var.resource_pool_comment
}

module "local_repo_vm" {
  for_each = var.local_repo_vm_enabled ? { this = true } : {}

  source = "../local_repo_vm"

  name                  = var.local_repo_vm_name
  node_name             = local.primary_node_name
  datastore_id          = coalesce(var.local_repo_vm_datastore_id, module.images.id)
  pool_id               = try(proxmox_virtual_environment_pool.platform[0].pool_id, null)
  snippets_datastore_id = module.snippets.id
  boot_image_id         = proxmox_virtual_environment_download_file.vm_template.id
  boot_image_kind       = var.vm_template_kind

  vm_id               = var.local_repo_vm_vm_id
  cpu_cores           = var.local_repo_vm_cpu_cores
  cpu_type            = var.local_repo_vm_cpu_type
  cpu_flags           = var.local_repo_vm_cpu_flags
  memory_mb           = var.local_repo_vm_memory_mb
  disk_size_gb        = var.local_repo_vm_disk_size_gb
  packages_disk_size_gb = var.local_repo_vm_packages_disk_size_gb
  network_bridge      = var.local_repo_vm_network_bridge
  ipv4_address        = var.local_repo_vm_ipv4_address
  ipv4_gateway        = var.local_repo_vm_ipv4_gateway
  dns_servers         = var.local_repo_vm_dns_servers
  dns_domain          = var.local_repo_vm_dns_domain
}
