output "cluster_name" {
  description = "Cluster name passed into the infra module."
  value       = var.cluster_name
}


output "discovered_nodes" {
  description = "Raw node data discovered from the Proxmox provider."
  value       = data.proxmox_virtual_environment_nodes.discovered
}
