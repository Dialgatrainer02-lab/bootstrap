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

output "api_address" {
  description = "OpenBao API address."
  value       = local.openbao_api_address
}

output "admin_username" {
  description = "Initial OpenBao admin username configured via cloud-init."
  value       = local.openbao_admin_username
}

output "initial_admin_password" {
  description = "Initial OpenBao admin password configured via cloud-init."
  value       = random_password.inital_admin_password.result
  sensitive   = true
}

output "config_kv_mount_path" {
  description = "KV mount path managed by the OpenBao config submodule."
  value       = module.config.kv_mount_path
}
