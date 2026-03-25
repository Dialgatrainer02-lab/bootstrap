

resource "vault_mount" "kv" {
  path        = var.kv_mount_path
  type        = "kv-v2"
  description = "KV v2 mount managed by Terraform"
}
