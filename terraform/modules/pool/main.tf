resource "proxmox_virtual_environment_pool" "pool" {
  pool_id = var.pool_name
  comment = var.pool_comment
}