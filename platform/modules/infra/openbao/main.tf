
# module "openbao_data" {
# source = "../datastore"
# 
# name = "openbao_data"
# path = "/var/lib/openbao-data"
# content = ["snippets"]
# }
# 
# 
# resource "proxmox_virtual_environment_file" "openbao_config" {
# content_type = "snippets"
# datastore_id = module.openbao_data.id
# node_name = data.proxmox_virtual_environment_nodes.discovered.names[0]
# source_file {
# path = "${path.module}/openbao/config.hcl"
# }
# }
# 
# 
# resource "random_bytes" "openbao_key" {
# length = 32
# }
# resource "proxmox_virtual_environment_file" "openbao_seal" {
# content_type = "snippets"
# datastore_id = module.openbao_data.id
# node_name = data.proxmox_virtual_environment_nodes.discovered.names[0]
# source_raw {
# file_name = "test-1.key"
# data = random_bytes.openbao_key.base64
# }
# }
# 
# output "name" {
# value = proxmox_virtual_environment_file.openbao_config
# }
# 
# module "openbao" {
# source = "../oci_container"
# 
# node_name = data.proxmox_virtual_environment_nodes.discovered.names[0]
# datastore_id = "local-zfs"
# image_datastore_id = "local"
# name = "openbao"
# image_ref = "docker.io/openbao/openbao:latest"
# dns_servers = ["1.1.1.1"]
# mount_points = [
# {
# path = "/openbao/config"
# volume = "/mnt/bindmounts/openbao"
# }
# ]
# 
# }