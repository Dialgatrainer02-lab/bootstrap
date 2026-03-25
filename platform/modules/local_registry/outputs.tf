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
