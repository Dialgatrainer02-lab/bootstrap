provider "proxmox" {
    endpoint = var.pve_endpoint
  # Choose one authentication method:
#   api_token = var.pve_api_token

  username = var.pve_username
  password = var.pve_password
  # because self-signed TLS certificate is in use
  insecure = true
  # uncomment (unless on Windows...)
  # tmp_dir  = "/var/tmp"

  ssh {
    agent = true

  }
}
