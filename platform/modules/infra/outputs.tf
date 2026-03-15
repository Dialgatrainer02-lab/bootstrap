output "cluster_name" {
  description = "Cluster name passed into the infra module."
  value       = var.cluster_name
}

output "nodes" {
  description = "Node definitions passed into the infra module."
  value       = var.nodes
}
