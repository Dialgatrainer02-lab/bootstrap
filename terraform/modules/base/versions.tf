terraform {
  required_version = "~> v1.12.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.95.1-rc1"
    }
  }
}
