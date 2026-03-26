# Auto-discover available Proxmox nodes for downstream modules.
data "proxmox_virtual_environment_nodes" "discovered" {}


locals {
  default_snippets_datastore_name = "${var.cluster_name}-snippets"
  default_snippets_datastore_path = "/var/lib/${var.cluster_name}-snippets"

  default_images_datastore_name = "${var.cluster_name}-images"
  default_images_datastore_path = "/var/lib/${var.cluster_name}-images"

  snippets_datastore_name = coalesce(var.snippets_datastore_name, local.default_snippets_datastore_name)
  snippets_datastore_path = coalesce(var.snippets_datastore_path, local.default_snippets_datastore_path)

  images_datastore_name = coalesce(var.images_datastore_name, local.default_images_datastore_name)
  images_datastore_path = coalesce(var.images_datastore_path, local.default_images_datastore_path)
  resource_pool_name    = coalesce(var.resource_pool_name, "${var.cluster_name}-pool")

  primary_node_name = data.proxmox_virtual_environment_nodes.discovered.names[1]

  service_feature_gates = merge({
    local_mirror   = true
    openbao        = false
    local_registry = false
  }, var.service_feature_gates)

  local_mirror_enabled   = lookup(local.service_feature_gates, "local_mirror", false)
  openbao_enabled        = lookup(local.service_feature_gates, "openbao", false)
  local_registry_enabled = lookup(local.service_feature_gates, "local_registry", false)

  service_subnet_prefix = split("/", var.service_network_subnet_cidr)[1]

  local_mirror_ip              = cidrhost(var.service_network_subnet_cidr, 50)
  local_mirror_ipv4_address    = "${local.local_mirror_ip}/${local.service_subnet_prefix}"
  local_mirror_health_check_ip = local.local_mirror_ip

  openbao_ip                  = cidrhost(var.service_network_subnet_cidr, 51)
  openbao_ipv4_address        = "${local.openbao_ip}/${local.service_subnet_prefix}"
  local_registry_ip           = cidrhost(var.service_network_subnet_cidr, 52)
  local_registry_ipv4_address = "${local.local_registry_ip}/${local.service_subnet_prefix}"

  local_mirror_name   = "${var.cluster_name}-local-mirror"
  openbao_name        = "${var.cluster_name}-openbao"
  local_registry_name = "${var.cluster_name}-local-registry"
  cluster_tag         = "cluster-${var.cluster_name}"

  service_vm_common_tags = [
    "service",
    local.cluster_tag,
  ]
  local_mirror_tags = concat(local.service_vm_common_tags, ["local-mirror"])
  openbao_tags      = concat(local.service_vm_common_tags, ["openbao"])
  local_registry_tags = concat(local.service_vm_common_tags, [
    "local-registry",
  ])

  vm_template_file_name = startswith(var.vm_template_file_name, "${var.cluster_name}-") ? var.vm_template_file_name : "${var.cluster_name}-${var.vm_template_file_name}"

  local_mirror_service_fqdn = var.service_dns_domain != null && trimspace(var.service_dns_domain) != "" ? "local-mirror.${var.service_dns_domain}" : "local-mirror"
  local_mirror_base_url     = "http://${local.local_mirror_service_fqdn}/repos/current"
  openbao_service_fqdn      = var.service_dns_domain != null && trimspace(var.service_dns_domain) != "" ? "openbao.${var.service_dns_domain}" : "openbao"
  openbao_service_api_url   = "http://${local.openbao_service_fqdn}:8200"
  pki_role_allowed_domains  = var.service_dns_domain != null && trimspace(var.service_dns_domain) != "" ? [trimspace(var.service_dns_domain)] : ["example.com"]
  service_vm_cpu_type       = "host"
}


module "snippets" {
  source = "../modules/infrastructure/datastore"

  name    = local.snippets_datastore_name
  path    = local.snippets_datastore_path
  pool_id = try(proxmox_virtual_environment_pool.platform[0].pool_id, null)
  content = ["snippets"]
}

module "images" {
  source = "../modules/infrastructure/datastore"

  name    = local.images_datastore_name
  path    = local.images_datastore_path
  content = ["import", "iso", "images", "vztmpl"]
  pool_id = try(proxmox_virtual_environment_pool.platform[0].pool_id, null)
}

resource "proxmox_virtual_environment_download_file" "vm_template" {
  node_name           = local.primary_node_name
  datastore_id        = module.images.id
  content_type        = "iso"
  url                 = var.vm_template_url
  file_name           = local.vm_template_file_name
  overwrite           = true
  overwrite_unmanaged = false
}

resource "proxmox_virtual_environment_pool" "platform" {
  count = local.resource_pool_name != null ? 1 : 0

  pool_id = local.resource_pool_name
  comment = var.resource_pool_comment
}

module "local_mirror" {
  for_each = local.local_mirror_enabled ? { this = true } : {}

  source = "../modules/local_mirror"

  name                  = local.local_mirror_name
  node_name             = local.primary_node_name
  datastore_id          = module.images.id
  pool_id               = try(proxmox_virtual_environment_pool.platform[0].pool_id, null)
  snippets_datastore_id = module.snippets.id
  boot_image_id         = proxmox_virtual_environment_download_file.vm_template.id
  boot_image_kind       = "disk"

  cpu_cores             = 2
  cpu_type              = "host"
  cpu_flags             = []
  memory_mb             = 4096
  disk_size_gb          = 20
  packages_disk_size_gb = 100
  repo_disk_device      = null
  ipv4_address          = local.local_mirror_ipv4_address
  ipv4_gateway          = var.service_network_gateway
  dns_servers           = null
  dns_domain            = var.service_dns_domain
  tags                  = local.local_mirror_tags
}

module "openbao" {
  for_each = local.local_mirror_enabled && local.openbao_enabled ? { this = true } : {}

  source = "../modules/openbao"

  name                  = local.openbao_name
  node_name             = local.primary_node_name
  datastore_id          = module.images.id
  pool_id               = try(proxmox_virtual_environment_pool.platform[0].pool_id, null)
  snippets_datastore_id = module.snippets.id
  boot_image_id         = proxmox_virtual_environment_download_file.vm_template.id
  boot_image_kind       = "disk"

  cpu_cores    = 2
  cpu_type     = local.service_vm_cpu_type
  cpu_flags    = []
  memory_mb    = 4096
  disk_size_gb = 40
  ipv4_address = local.openbao_ipv4_address
  ipv4_gateway = var.service_network_gateway
  dns_servers  = []
  dns_domain   = var.service_dns_domain
  tags         = local.openbao_tags

  mirror_base_url         = local.local_mirror_base_url
  local_mirror_service_ip = local.local_mirror_ip
}

module "openbao_config" {
  for_each = local.local_mirror_enabled && local.openbao_enabled ? { this = true } : {}

  source = "../modules/openbao/config"

  pki_api_base_url         = local.openbao_service_api_url
  pki_cluster_base_url     = local.openbao_service_api_url
  pki_wait_base_url        = "http://${local.openbao_ip}:8200"
  pki_role_allowed_domains = local.pki_role_allowed_domains

  depends_on = [module.openbao]
}

module "local_registry" {
  for_each = local.local_mirror_enabled && local.openbao_enabled && local.local_registry_enabled ? { this = true } : {}

  source = "../modules/local_registry"

  name                  = local.local_registry_name
  node_name             = local.primary_node_name
  datastore_id          = module.images.id
  pool_id               = try(proxmox_virtual_environment_pool.platform[0].pool_id, null)
  snippets_datastore_id = module.snippets.id
  boot_image_id         = proxmox_virtual_environment_download_file.vm_template.id
  boot_image_kind       = "disk"

  cpu_cores    = 2
  cpu_type     = local.service_vm_cpu_type
  cpu_flags    = []
  memory_mb    = 4096
  disk_size_gb = 40
  ipv4_address = local.local_registry_ipv4_address
  ipv4_gateway = var.service_network_gateway
  dns_servers  = []
  dns_domain   = var.service_dns_domain
  tags         = local.local_registry_tags

  mirror_base_url                 = local.local_mirror_base_url
  local_mirror_service_ip         = local.local_mirror_ip
  openbao_service_ip              = local.openbao_ip
  openbao_root_ca_certificate_pem = module.openbao_config["this"].root_ca_certificate

  depends_on = [module.openbao]
}
