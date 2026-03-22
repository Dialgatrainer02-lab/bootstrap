output "cluster_name" {
  description = "Cluster name passed into the infra module."
  value       = var.cluster_name
}


output "discovered_nodes" {
  description = "Raw node data discovered from the Proxmox provider."
  value       = data.proxmox_virtual_environment_nodes.discovered
}

output "primary_node_name" {
  description = "Primary node name used for shared downloads/uploads."
  value       = local.primary_node_name
}

output "snippets_datastore_id" {
  description = "Storage ID for the shared snippets datastore."
  value       = module.snippets.id
}

output "images_datastore_id" {
  description = "Storage ID for the shared images datastore."
  value       = module.images.id
}

output "vm_template_file_id" {
  description = "Proxmox file id of the downloaded VM template/boot image."
  value       = proxmox_virtual_environment_download_file.vm_template.id
}

output "local_repo_vm_id" {
  description = "VM resource id for the local repo VM (if enabled)."
  value       = try(module.local_repo_vm["this"].id, null)
}

output "local_repo_vm_vm_id" {
  description = "VM id for the local repo VM (if enabled)."
  value       = try(module.local_repo_vm["this"].vm_id, null)
}

output "local_repo_vm_cloud_init_user_data_file_id" {
  description = "Proxmox snippet file id for the local repo VM user-data (if enabled)."
  value       = try(module.local_repo_vm["this"].cloud_init_user_data_file_id, null)
}
