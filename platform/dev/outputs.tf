output "cluster_name" {
  description = "Cluster name passed into the infra module."
  value       = var.cluster_name
}

# output "discovered_nodes" {
# description = "Raw node data discovered from the Proxmox provider."
# value       = data.proxmox_virtual_environment_nodes.discovered
# }

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

output "resource_pool_id" {
  description = "Proxmox resource pool ID used to group platform resources."
  value       = try(proxmox_virtual_environment_pool.platform[0].pool_id, null)
}

output "local_mirror_health_check_url" {
  description = "HTTP URL used by the local mirror VM health check."
  value       = local.local_mirror_enabled ? "http://${local.local_mirror_health_check_ip}/repos/current/" : null
}

output "vm_template_file_id" {
  description = "Proxmox file id of the downloaded VM template/boot image."
  value       = proxmox_virtual_environment_download_file.vm_template.id
}

output "local_mirror_id" {
  description = "VM resource id for the local mirror VM (if enabled)."
  value       = try(module.local_mirror["this"].id, null)
}

output "local_mirror_vm_id" {
  description = "VM id for the local mirror VM (if enabled)."
  value       = try(module.local_mirror["this"].vm_id, null)
}

output "local_mirror_cloud_init_user_data_file_id" {
  description = "Proxmox snippet file id for the local mirror VM user-data (if enabled)."
  value       = try(module.local_mirror["this"].cloud_init_user_data_file_id, null)
}

output "local_mirror_ipv4_address" {
  description = "Derived IPv4 CIDR address used by the local mirror service VM."
  value       = local.local_mirror_enabled ? local.local_mirror_ipv4_address : null
}

output "openbao_id" {
  description = "VM resource id for the openbao VM (if enabled)."
  value       = try(module.openbao["this"].id, null)
}

output "openbao_vm_id" {
  description = "VM id for the openbao VM (if enabled)."
  value       = try(module.openbao["this"].vm_id, null)
}

output "openbao_cloud_init_user_data_file_id" {
  description = "Proxmox snippet file id for the openbao VM user-data (if enabled)."
  value       = try(module.openbao["this"].cloud_init_user_data_file_id, null)
}

output "openbao_ipv4_address" {
  description = "Derived IPv4 CIDR address used by the openbao service VM."
  value       = local.local_mirror_enabled && local.openbao_enabled ? local.openbao_ipv4_address : null
}

output "openbao_api_address" {
  description = "OpenBao API address for provider configuration."
  value       = try(module.openbao["this"].api_address, null)
}

output "openbao_admin_username" {
  description = "OpenBao admin username for provider configuration."
  value       = try(module.openbao["this"].admin_username, null)
}

output "openbao_initial_admin_password" {
  description = "OpenBao initial admin password for provider configuration."
  value       = try(module.openbao["this"].initial_admin_password, null)
  sensitive   = true
}

output "openbao_config_kv_mount_path" {
  description = "KV mount path configured by the OpenBao config submodule."
  value       = try(module.openbao_config["this"].kv_mount_path, null)
}

output "openbao_intermediate_ca_certificate" {
  description = "PEM-encoded OpenBao intermediate CA certificate."
  value       = try(module.openbao_config["this"].intermediate_ca_certificate, null)
}

output "openbao_root_ca_certificate" {
  description = "PEM-encoded OpenBao root CA certificate."
  value       = try(module.openbao_config["this"].root_ca_certificate, null)
}

output "local_registry_id" {
  description = "VM resource id for the local registry VM (if enabled)."
  value       = try(module.local_registry["this"].id, null)
}

output "local_registry_vm_id" {
  description = "VM id for the local registry VM (if enabled)."
  value       = try(module.local_registry["this"].vm_id, null)
}

output "local_registry_cloud_init_user_data_file_id" {
  description = "Proxmox snippet file id for the local registry VM user-data (if enabled)."
  value       = try(module.local_registry["this"].cloud_init_user_data_file_id, null)
}

output "local_registry_ipv4_address" {
  description = "Derived IPv4 CIDR address used by the local registry service VM."
  value       = local.local_mirror_enabled && local.openbao_enabled && local.local_registry_enabled ? local.local_registry_ipv4_address : null
}
