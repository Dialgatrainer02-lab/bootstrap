
resource "vault_mount" "kv" {
  path        = var.kv_mount_path
  type        = "kv-v2"
  description = "KV v2 mount managed by Terraform"
}


locals {
  default_3y_in_sec  = 94608000
  default_1y_in_sec  = 31536000
  default_1hr_in_sec = 3600
}

resource "vault_mount" "pki_iss" {
  path                  = "pki_iss"
  type                  = "pki"
  description           = "PKI engine hosting issuing CA"
  max_lease_ttl_seconds = local.default_1hr_in_sec
}

resource "vault_mount" "pki_int" {
  path                      = "pki_int"
  type                      = "pki"
  description               = "PKI engine hosting intermediate CA"
  max_lease_ttl_seconds     = local.default_3y_in_sec
  default_lease_ttl_seconds = local.default_1y_in_sec
}

locals {
  external_ca_signer_command = <<-EOT
    set -euo pipefail
    certstrap --depot-path root sign \
      --CA "Example Labs Root CA v1" \
      --intermediate \
      --csr "$CSR_FILE" \
      --expires "5 years" \
      --path-length 1 \
      --cert "$SIGNED_CERT_FILE" \
      "Example Labs Intermediate CA v1.1"
  EOT

  external_ca_csr_file_path = startswith(var.external_ca_csr_file_path, "/") ? var.external_ca_csr_file_path : "${path.root}/root/${trimprefix(trimprefix(var.external_ca_csr_file_path, "./"), "root/")}"

  external_ca_signed_intermediate_file_path = startswith(var.external_ca_signed_intermediate_file_path, "/") ? var.external_ca_signed_intermediate_file_path : "${path.root}/root/${trimprefix(trimprefix(var.external_ca_signed_intermediate_file_path, "./"), "root/")}"

  pki_cluster_base_url = coalesce(var.pki_cluster_base_url, var.pki_api_base_url)
}

resource "vault_pki_secret_backend_config_urls" "pki_int" {
  backend = vault_mount.pki_int.path

  issuing_certificates = [
    "${var.pki_api_base_url}/v1/${vault_mount.pki_int.path}/ca",
  ]
  crl_distribution_points = [
    "${var.pki_api_base_url}/v1/${vault_mount.pki_int.path}/crl",
  ]
  ocsp_servers = [
    "${var.pki_api_base_url}/v1/${vault_mount.pki_int.path}/ocsp",
  ]
}

resource "vault_pki_secret_backend_config_cluster" "pki_int" {
  backend  = vault_mount.pki_int.path
  path     = "${local.pki_cluster_base_url}/v1/${vault_mount.pki_int.path}"
  aia_path = "${var.pki_api_base_url}/v1/${vault_mount.pki_int.path}"
}

resource "vault_pki_secret_backend_config_urls" "pki_iss" {
  backend = vault_mount.pki_iss.path

  issuing_certificates = [
    "${var.pki_api_base_url}/v1/${vault_mount.pki_iss.path}/ca",
  ]
  crl_distribution_points = [
    "${var.pki_api_base_url}/v1/${vault_mount.pki_iss.path}/crl",
  ]
  ocsp_servers = [
    "${var.pki_api_base_url}/v1/${vault_mount.pki_iss.path}/ocsp",
  ]
}

resource "vault_pki_secret_backend_config_cluster" "pki_iss" {
  backend  = vault_mount.pki_iss.path
  path     = "${local.pki_cluster_base_url}/v1/${vault_mount.pki_iss.path}"
  aia_path = "${var.pki_api_base_url}/v1/${vault_mount.pki_iss.path}"
}

module "issuer_v1_1" {
  source = "./external_ca"

  issuer = {
    name             = "v1.1"
    backend          = "pki_int"
    organization     = "Example"
    certificate_name = "Example Labs Intermediate CA v1.1"
    key_type         = "ec"
    key_bits         = 256
  }

  signer_command                = coalesce(var.external_ca_signer_command, local.external_ca_signer_command)
  csr_file_path                 = local.external_ca_csr_file_path
  signed_intermediate_file_path = local.external_ca_signed_intermediate_file_path

  depends_on = [
    vault_mount.pki_int,
    vault_pki_secret_backend_config_urls.pki_int,
    vault_pki_secret_backend_config_cluster.pki_int,
  ]
}
# 


module "issuer_v1_1_1" {
  source = "./internal_ca"
  issuer = {
    backend          = vault_mount.pki_iss.path
    parent_backend   = vault_mount.pki_int.path
    parent_issuer    = module.issuer_v1_1.issuer_id
    name             = "test"
    organization     = "Example"
    certificate_name = "Example Labs Issuing CA v1.1.1"
    key_type         = "ec"
    key_bits         = 256
  }
  role = {
    allowed_domains = var.pki_role_allowed_domains
    allow_ip_sans   = true
    no_store        = true
  }
  depends_on = [
    vault_mount.pki_iss,
    vault_pki_secret_backend_config_urls.pki_iss,
    vault_pki_secret_backend_config_cluster.pki_iss,
    module.issuer_v1_1,
  ]
}
