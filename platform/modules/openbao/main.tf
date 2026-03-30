locals {
  openbao_advertise_ip      = var.ipv4_address != "dhcp" ? split("/", var.ipv4_address)[0] : var.name
  openbao_api_address       = "http://${local.openbao_advertise_ip}:8200"
  openbao_service_fqdn      = var.dns_domain != null && trimspace(var.dns_domain) != "" ? "openbao.${var.dns_domain}" : "openbao"
  local_mirror_service_fqdn = var.dns_domain != null && trimspace(var.dns_domain) != "" ? "local-mirror.${var.dns_domain}" : "local-mirror"
  openbao_admin_username    = "admin"

  base_cloud_init_fragment = templatefile("${path.module}/../shared/cloudinit/fragments/base.yaml.tftpl", {
    hostname            = var.name
    package_update      = false
    package_upgrade     = false
    ssh_authorized_keys = local.authorized_keys
  })
  hosts_cloud_init_fragment = templatefile("${path.module}/../shared/cloudinit/fragments/hosts-openbao-local-mirror.yaml.tftpl", {
    openbao_service_fqdn      = local.openbao_service_fqdn
    openbao_service_ip        = local.openbao_advertise_ip
    local_mirror_service_fqdn = local.local_mirror_service_fqdn
    local_mirror_service_ip   = var.local_mirror_service_ip
  })
  local_repos_cloud_init_fragment = templatefile("${path.module}/../shared/cloudinit/fragments/local-yum-repos.yaml.tftpl", {
    mirror_base_url = var.mirror_base_url
    mirror_wait_url = "http://${var.local_mirror_service_ip}/repos/"
  })
  service_cloud_init_fragment = templatefile("${path.module}/cloud-init.yaml.tftpl", {
    openbao_api_addr               = local.openbao_service_fqdn
    openbao_cluster_addr           = local.openbao_service_fqdn
    openbao_raft_node_id           = var.name
    openbao_raft_data_dir          = var.openbao_raft_data_dir
    openbao_initial_admin_password = random_password.inital_admin_password.result
    openbao_key_0                  = random_bytes.key_0.base64
  })
  rendered_user_data = coalesce(var.cloud_init_user_data, try(data.cloudinit_config.user_data[0].rendered, null))
}

locals {
  authorized_keys = distinct(concat(
    var.ssh_authorized_keys,
    [trimspace(tls_private_key.openbao_vm_ssh.public_key_openssh)],
  ))
}

resource "tls_private_key" "openbao_vm_ssh" {
  algorithm = "ED25519"
}

resource "local_sensitive_file" "openbao_vm_ssh_private_key" {
  filename        = "${path.root}/keys/openbao"
  content         = tls_private_key.openbao_vm_ssh.private_key_openssh
  file_permission = "0600"
}

resource "random_password" "inital_admin_password" {
  length  = 32
  special = false
}

resource "random_bytes" "key_0" {
  length = 32
}

data "cloudinit_config" "user_data" {
  count = var.cloud_init_user_data == null ? 1 : 0

  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = local.base_cloud_init_fragment
  }

  part {
    content_type = "text/cloud-config"
    content      = local.hosts_cloud_init_fragment
  }

  part {
    content_type = "text/cloud-config"
    content      = local.local_repos_cloud_init_fragment
  }

  part {
    content_type = "text/cloud-config"
    content      = local.service_cloud_init_fragment
  }
}

resource "proxmox_virtual_environment_file" "cloud_init_user_data" {
  content_type = "snippets"
  datastore_id = var.snippets_datastore_id
  node_name    = var.node_name

  source_raw {
    file_name = "${var.name}-user-data.yaml"
    data      = local.rendered_user_data
  }
}

module "vm" {
  source = "../infrastructure/vm"

  name         = var.name
  node_name    = var.node_name
  datastore_id = var.datastore_id
  pool_id      = var.pool_id

  vm_id     = var.vm_id
  cpu_cores = var.cpu_cores
  cpu_type  = var.cpu_type
  cpu_flags = var.cpu_flags
  memory_mb = var.memory_mb

  disk_size_gb    = var.disk_size_gb
  network_bridge  = var.network_bridge
  ipv4_address    = var.ipv4_address
  ipv4_gateway    = var.ipv4_gateway
  dns_servers     = var.dns_servers
  dns_domain      = var.dns_domain
  tags            = var.tags
  boot_image_id   = var.boot_image_id
  boot_image_kind = var.boot_image_kind

  cloud_init_user_data_file_id = proxmox_virtual_environment_file.cloud_init_user_data.id
}
