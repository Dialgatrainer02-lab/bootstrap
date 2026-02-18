terraform {
  required_version = "~> v1.12.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.95.1-rc1"
    }
    talos = {
      source  = "siderolabs/talos"
      version = ">= 0.10.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.2.1"
    }
  }
}
