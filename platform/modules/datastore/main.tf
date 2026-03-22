resource "proxmox_virtual_environment_storage_directory" "this" {
  count = var.type == "directory" ? 1 : 0

  id      = var.name
  path    = var.path
  content = var.content
  nodes   = var.nodes
  shared  = var.shared
  disable = var.disable
}
