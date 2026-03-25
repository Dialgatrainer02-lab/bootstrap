resource "vault_pki_secret_backend_key" "this" {
  backend  = var.issuer.backend
  type     = "internal"
  key_type = var.issuer.key_type
  key_bits = var.issuer.key_bits
  key_name = var.issuer.name
}

resource "vault_pki_secret_backend_intermediate_cert_request" "this" {
  backend      = var.issuer.backend
  type         = "existing"
  organization = var.issuer.organization
  common_name  = var.issuer.certificate_name
  key_ref      = vault_pki_secret_backend_key.this.key_id
}

resource "vault_pki_secret_backend_root_sign_intermediate" "this" {

  backend        = var.issuer.parent_backend
  issuer_ref     = var.issuer.parent_issuer
  csr            = vault_pki_secret_backend_intermediate_cert_request.this.csr
  common_name    = var.issuer.certificate_name
  use_csr_values = true
  ttl            = var.issuer.ttl
}

resource "vault_pki_secret_backend_intermediate_set_signed" "this" {
  backend     = var.issuer.backend
  certificate = vault_pki_secret_backend_root_sign_intermediate.this.certificate
}

resource "vault_pki_secret_backend_issuer" "this" {
  backend     = var.issuer.backend
  issuer_ref  = vault_pki_secret_backend_intermediate_set_signed.this.imported_issuers[0]
  issuer_name = var.issuer.name
}

resource "vault_pki_secret_backend_role" "issuing" {
  backend                     = var.issuer.backend
  name                        = var.role.name
  organization                = [var.issuer.organization]
  key_type                    = var.issuer.key_type
  key_bits                    = var.issuer.key_bits
  max_ttl                     = var.role.max_ttl_seconds
  allowed_domains             = var.role.allowed_domains
  allow_subdomains            = var.role.allow_subdomains
  allow_ip_sans               = var.role.allow_ip_sans
  allow_wildcard_certificates = var.role.allow_wildcard_certificates
  issuer_ref                  = vault_pki_secret_backend_issuer.this.issuer_ref
}
