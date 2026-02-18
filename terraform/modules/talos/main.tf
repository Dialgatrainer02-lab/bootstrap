

data "proxmox_virtual_environment_nodes" "available_nodes" {}

data "proxmox_virtual_environment_datastores" "avalible_datastores" {
  for_each  = toset(data.proxmox_virtual_environment_nodes.available_nodes.names)
  node_name = each.key
}

locals {
  node_datastores = { for node in toset(data.proxmox_virtual_environment_nodes.available_nodes.names) : node => data.proxmox_virtual_environment_datastores.avalible_datastores[node].datastores }
  image_datastore = {
    for node_name, datastores in local.node_datastores :
    node_name => (
      [for ds in datastores : ds.id if ds.id == "local-zfs"][0]
    )
  }
  asset_datastore = {
    for node_name, datastores in local.node_datastores :
    node_name => (
      [for ds in datastores : ds.id if ds.id == "local"][0]
    )
  }
}

resource "proxmox_virtual_environment_download_file" "talos_iso" {
  url          = data.talos_image_factory_urls.this.urls.iso_secureboot
  node_name    = var.node_name
  datastore_id = local.asset_datastore[var.node_name]
  content_type = "iso"
}

resource "proxmox_virtual_environment_vm" "management_cluster" {
  node_name   = var.node_name
  name        = "management-cluster"
  description = "Managed by Terraform"
  tags        = concat(["terraform"], var.tags)
  pool_id     = var.pool_id

  machine = "q35"
  bios    = "ovmf"

  agent {
    # read 'Qemu guest agent' section, change to true only when ready
    enabled = true
  }

  cpu {
    flags = []
    cores = 2
    type  = "host" # recommended for modern CPUs
  }

  memory {
    dedicated = 2048
    floating  = 0 # set equal to dedicated to enable ballooning
  }
  boot_order = ["virtio0"]

  disk {
    interface    = "virtio0"
    file_format  = "raw"
    size         = 10
    datastore_id = local.image_datastore[var.node_name]
  }

  tpm_state {
    version      = "v2.0"
    datastore_id = local.image_datastore[var.node_name]
  }

  efi_disk {
    datastore_id      = local.image_datastore[var.node_name]
    type              = "4m"
    pre_enrolled_keys = false
  }

  cdrom {
    file_id   = proxmox_virtual_environment_download_file.talos_iso.id
    interface = "scsi0"
  }


  network_device {
    bridge = "vmbr0"
  }

  operating_system {
    type = "l26"
  }

  initialization {
    datastore_id = local.image_datastore[var.node_name]
    interface    = "sata0"

    ip_config {
      ipv4 {
        address = var.talos_ip_config.ipv4.address
        gateway = var.talos_ip_config.ipv4.gateway
      }
      ipv6 {
        address = var.talos_ip_config.ipv6.address
        gateway = var.talos_ip_config.ipv6.gateway
      }
    }
    dns {
      servers = var.talos_dns_servers
    }
  }
}

