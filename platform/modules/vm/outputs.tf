output "id" {
  description = "VM resource id."
  value       = proxmox_virtual_environment_vm.this.id
}

output "vm_id" {
  description = "VM id."
  value       = proxmox_virtual_environment_vm.this.vm_id
}

output "boot_image_file_id" {
  description = "Resolved Proxmox file id used as the boot image."
  value       = local.boot_image_file_id
}

output "boot_image_url" {
  description = "Boot image URL, if provided."
  value       = var.boot_image_url
}

output "boot_image_download_id" {
  description = "Download file id for the boot image, if downloaded."
  value       = try(proxmox_virtual_environment_download_file.boot[0].id, null)
}

output "boot_image_download_size" {
  description = "Size of the downloaded boot image, in bytes."
  value       = try(proxmox_virtual_environment_download_file.boot[0].size, null)
}

output "vm" {
  value       = proxmox_virtual_environment_vm.this
  description = "Proxmox vm resource"
  sensitive   = true
}