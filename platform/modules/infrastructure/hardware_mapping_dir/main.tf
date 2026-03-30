resource "proxmox_virtual_environment_hardware_mapping_dir" "this" {
  name    = var.name
  comment = var.comment
  map     = var.map
}
