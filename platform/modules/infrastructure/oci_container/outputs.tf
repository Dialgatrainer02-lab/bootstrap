output "id" {
  description = "Container resource id."
  value       = proxmox_virtual_environment_container.this.id
}


output "vm_id" {
  description = "Container VM/CT id."
  value       = proxmox_virtual_environment_container.this.vm_id
}

output "image_ref" {
  description = "OCI image reference used for the container template."
  value       = var.image_ref
}

output "image_id" {
  description = "Proxmox file id for the pulled OCI image."
  value       = proxmox_virtual_environment_oci_image.this.id
}

output "image_size" {
  description = "Size of the pulled OCI image, in bytes."
  value       = proxmox_virtual_environment_oci_image.this.size
}

output "env" {
  description = "Requested environment variables (not applied by the provider)."
  value       = var.env
}
