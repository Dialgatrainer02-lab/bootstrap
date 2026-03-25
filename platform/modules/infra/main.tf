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

  primary_node_name = data.proxmox_virtual_environment_nodes.discovered.names[0]

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

  local_mirror_service_fqdn = var.service_dns_domain != null && trimspace(var.service_dns_domain) != "" ? "local-mirror.${var.service_dns_domain}" : "local-mirror"
  local_mirror_base_url     = "http://${local.local_mirror_service_fqdn}/repos/current"
}

module "snippets" {
  source = "../datastore"

  name    = local.snippets_datastore_name
  path    = local.snippets_datastore_path
  pool_id = try(proxmox_virtual_environment_pool.platform[0].pool_id, null)
  content = ["snippets"]
}

module "images" {
  source = "../datastore"

  name    = local.images_datastore_name
  path    = local.images_datastore_path
  content = ["iso", "images", "vztmpl"]
  pool_id = try(proxmox_virtual_environment_pool.platform[0].pool_id, null)
}

resource "proxmox_virtual_environment_download_file" "vm_template" {
  node_name           = local.primary_node_name
  datastore_id        = module.images.id
  content_type        = "iso"
  url                 = var.vm_template_url
  file_name           = var.vm_template_file_name
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

  source = "../local_mirror"

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
  tags                  = ["service", "local-mirror", var.cluster_name]
}

# resource "terraform_data" "local_mirror_health_check" {
# count = local.local_mirror_enabled ? 1 : 0
# 
# triggers_replace = {
# ip    = local.local_mirror_health_check_ip
# path  = "/repos/current/"
# vm_id = tostring(try(module.local_mirror["this"].vm_id, ""))
# }
# 
# depends_on = [module.local_mirror]
# 
# provisioner "local-exec" {
# command = <<-EOT
# bash -lc 'for i in $$(seq 1 30); do curl -fsS "http://${local.local_mirror_health_check_ip}/repos/current/" >/dev/null && exit 0; sleep 10; done; echo "Repository health check failed: http://${local.local_mirror_health_check_ip}/repos/current/" >&2; exit 1'
# EOT
# }
# }

module "openbao" {
  for_each = local.local_mirror_enabled && local.openbao_enabled ? { this = true } : {}

  source = "./openbao"

  name                  = local.openbao_name
  node_name             = local.primary_node_name
  datastore_id          = module.images.id
  pool_id               = try(proxmox_virtual_environment_pool.platform[0].pool_id, null)
  snippets_datastore_id = module.snippets.id
  boot_image_id         = proxmox_virtual_environment_download_file.vm_template.id
  boot_image_kind       = "disk"

  cpu_cores    = 2
  cpu_type     = "host"
  cpu_flags    = []
  memory_mb    = 4096
  disk_size_gb = 40
  ipv4_address = local.openbao_ipv4_address
  ipv4_gateway = var.service_network_gateway
  dns_servers  = []
  dns_domain   = var.service_dns_domain
  tags         = ["service", "openbao", var.cluster_name]

  mirror_base_url         = local.local_mirror_base_url
  local_mirror_service_ip = local.local_mirror_ip
}

module "local_registry" {
  for_each = local.local_mirror_enabled && local.openbao_enabled && local.local_registry_enabled ? { this = true } : {}

  source = "../local_registry"

  name                  = local.local_registry_name
  node_name             = local.primary_node_name
  datastore_id          = module.images.id
  pool_id               = try(proxmox_virtual_environment_pool.platform[0].pool_id, null)
  snippets_datastore_id = module.snippets.id
  boot_image_id         = proxmox_virtual_environment_download_file.vm_template.id
  boot_image_kind       = "disk"

  cpu_cores    = 2
  cpu_type     = "host"
  cpu_flags    = []
  memory_mb    = 4096
  disk_size_gb = 40
  ipv4_address = local.local_registry_ipv4_address
  ipv4_gateway = var.service_network_gateway
  dns_servers  = []
  dns_domain   = var.service_dns_domain
  tags         = ["service", "local-registry", var.cluster_name]

  mirror_base_url                         = local.local_mirror_base_url
  local_mirror_service_ip                 = local.local_mirror_ip
  openbao_service_ip                      = local.openbao_ip
  openbao_intermediate_ca_certificate_pem = module.openbao["this"].intermediate_ca_certificate
}
