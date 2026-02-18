output "schematic_id" {
  value = talos_image_factory_schematic.this.id
}

output "talos_config" {
  value = data.talos_client_configuration.this.talos_config
}

output "kube_config" {
  value = talos_cluster_kubeconfig.this.kubeconfig_raw
}