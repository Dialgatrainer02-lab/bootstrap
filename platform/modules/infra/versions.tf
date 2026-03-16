terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
    talos = {
      source = "siderolabs/talos"
    }
    cloudinit = {
      source = "hashicorp/cloudinit"
    }
    random= { 
      source = "hashicorp/random" 
      version = "3.8.1"
    } 
  }
}
