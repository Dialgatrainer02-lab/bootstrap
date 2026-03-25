locals {
  csr_file_path = startswith(var.csr_file_path, "/") ? var.csr_file_path : "${path.root}/${var.csr_file_path}"

  signed_intermediate_file_path = startswith(var.signed_intermediate_file_path, "/") ? var.signed_intermediate_file_path : "${path.root}/${var.signed_intermediate_file_path}"
}

resource "terraform_data" "prepare_paths" {
  triggers_replace = {
    csr_dir    = dirname(local.csr_file_path)
    signed_dir = dirname(local.signed_intermediate_file_path)
  }

  provisioner "local-exec" {
    command = "mkdir -p \"${dirname(local.csr_file_path)}\" \"${dirname(local.signed_intermediate_file_path)}\""
  }
}

# Generate a key.
resource "vault_pki_secret_backend_key" "this" {
  backend  = var.issuer.backend
  type     = "internal"
  key_type = var.issuer.key_type
  key_bits = var.issuer.key_bits
  key_name = var.issuer.name
}

# Generate a CSR in OpenBao.
resource "vault_pki_secret_backend_intermediate_cert_request" "this" {
  backend      = var.issuer.backend
  type         = "existing"
  organization = var.issuer.organization
  common_name  = var.issuer.certificate_name
  key_ref      = vault_pki_secret_backend_key.this.key_id
}

# Write the CSR to a local file for external signing.
resource "local_sensitive_file" "csr" {
  filename = local.csr_file_path
  content  = vault_pki_secret_backend_intermediate_cert_request.this.csr

  depends_on = [terraform_data.prepare_paths]
}

# Sign the CSR with a local command.
resource "terraform_data" "sign_intermediate" {
  triggers_replace = {
    csr_sha256                    = sha256(vault_pki_secret_backend_intermediate_cert_request.this.csr)
    csr_file_path                 = local.csr_file_path
    signed_intermediate_file_path = local.signed_intermediate_file_path
    signer_command                = var.signer_command
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-lc"]
    command     = var.signer_command
    environment = {
      CSR_FILE         = local.csr_file_path
      SIGNED_CERT_FILE = local.signed_intermediate_file_path
    }
  }

  depends_on = [local_sensitive_file.csr]
}

# Read the externally signed intermediate certificate.
data "local_file" "signed_intermediate" {
  filename = local.signed_intermediate_file_path

  depends_on = [terraform_data.sign_intermediate]
}

# Store the signed certificate in OpenBao.
resource "vault_pki_secret_backend_intermediate_set_signed" "this" {
  backend     = var.issuer.backend
  certificate = trimspace(data.local_file.signed_intermediate.content)
}

# Name the issuer.
resource "vault_pki_secret_backend_issuer" "this" {
  backend     = var.issuer.backend
  issuer_ref  = vault_pki_secret_backend_intermediate_set_signed.this.imported_issuers[0]
  issuer_name = var.issuer.name
}
