resource "proxmox_virtual_environment_storage_directory" "this" {
  count = var.type == "directory" ? 1 : 0

  id      = var.name
  path    = var.path
  content = var.content
  nodes   = var.nodes
  shared  = var.shared
  disable = var.disable
}

resource "proxmox_virtual_environment_pool_membership" "this" {
  count      = var.attach_to_pool ? 1 : 0
  pool_id    = var.pool_id
  storage_id = proxmox_virtual_environment_storage_directory.this[0].id

}
