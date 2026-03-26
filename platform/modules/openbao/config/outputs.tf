output "kv_mount_path" {
  description = "Configured KV mount path."
  value       = vault_mount.kv.path
}

output "intermediate_ca_certificate" {
  description = "PEM-encoded OpenBao intermediate CA certificate."
  value       = module.issuer_v1_1.certificate
}
