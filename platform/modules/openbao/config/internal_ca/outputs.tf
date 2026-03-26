output "csr" {
  description = "Generated issuing CA CSR PEM."
  value       = vault_pki_secret_backend_intermediate_cert_request.this.csr
  sensitive   = true
}

output "issuer_ref" {
  description = "Issuer reference created in the issuing backend."
  value       = vault_pki_secret_backend_issuer.this.issuer_ref
}

output "role_name" {
  description = "Name of the issuing role."
  value       = vault_pki_secret_backend_role.issuing.name
}
