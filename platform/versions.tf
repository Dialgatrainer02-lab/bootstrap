terraform {
  required_version = ">= 1.6.0"

  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.98.1"
    }
    talos = {
      source = "siderolabs/talos"
      version = "0.10.1"
    }
    cloudinit = {
      source = "hashicorp/cloudinit"
      version = "2.3.7"
    }
  }
}
