output "id" {
  description = "Hardware directory mapping ID."
  value       = proxmox_virtual_environment_hardware_mapping_dir.this.id
}

output "name" {
  description = "Hardware directory mapping name."
  value       = proxmox_virtual_environment_hardware_mapping_dir.this.name
}

output "comment" {
  description = "Hardware directory mapping comment."
  value       = proxmox_virtual_environment_hardware_mapping_dir.this.comment
}

output "map" {
  description = "Hardware directory mapping entries."
  value       = proxmox_virtual_environment_hardware_mapping_dir.this.map
}
