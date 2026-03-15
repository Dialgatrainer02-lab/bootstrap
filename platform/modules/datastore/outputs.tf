output "storage_id" {
  value       = try(proxmox_virtual_environment_storage_directory.this[0].id, null)
  description = "Storage ID for the datastore."
}

output "path" {
  value       = try(proxmox_virtual_environment_storage_directory.this[0].path, null)
  description = "Filesystem path for the datastore."
}

output "type" {
  value       = var.type
  description = "Datastore type."
}
