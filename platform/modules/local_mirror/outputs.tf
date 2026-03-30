output "id" {
  description = "VM resource id."
  value       = module.vm.id
}

output "vm_id" {
  description = "VM id."
  value       = module.vm.vm_id
}

output "cloud_init_user_data_file_id" {
  description = "Proxmox file id of the uploaded cloud-init user-data snippet."
  value       = proxmox_virtual_environment_file.cloud_init_user_data.id
}

output "repos_archive_file_id" {
  description = "Proxmox file id of the uploaded local mirror repository archive."
  value       = proxmox_virtual_environment_file.repos_archive.id
}

output "virtiofs_dir_mapping_id" {
  description = "Proxmox hardware directory mapping id created for virtiofs, if enabled."
  value       = try(module.virtiofs_dir_mapping[0].id, null)
}

output "virtiofs_dir_mapping_name" {
  description = "Proxmox hardware directory mapping name created for virtiofs, if enabled."
  value       = try(module.virtiofs_dir_mapping[0].name, null)
}
