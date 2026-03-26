output "kv_mount_path" {
  description = "Configured KV mount path."
  value       = vault_mount.kv.path
}

output "intermediate_ca_certificate" {
  description = "PEM-encoded OpenBao intermediate CA certificate."
  value       = module.issuer_v1_1.certificate
}

output "root_ca_certificate" {
  description = "PEM-encoded external root CA certificate used as trust anchor."
  value       = trimspace(data.local_file.external_ca_root_certificate.content)
}
