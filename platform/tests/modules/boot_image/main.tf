resource "proxmox_virtual_environment_download_file" "this" {
  node_name           = var.node_name
  datastore_id        = var.datastore_id
  content_type        = var.content_type
  url                 = var.url
  file_name           = var.file_name
  overwrite           = var.overwrite
  overwrite_unmanaged = var.overwrite_unmanaged
}

