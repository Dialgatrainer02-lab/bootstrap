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

resource "proxmox_virtual_environment_download_file" "boot_image" {
  url          = var.boot_image
  node_name    = var.node_name
  datastore_id = local.asset_datastore[var.node_name]
  content_type = "import"
}

resource "proxmox_virtual_environment_file" "user_data" {
  datastore_id = var.cloud_init_datastore_id
  node_name    = var.node_name

  source_raw {
    data      = var.user_data
    file_name = var.user_data_file_name
  }
}

resource "proxmox_virtual_environment_vm" "base_template" {
  node_name   = var.node_name
  name        = "base-template"
  description = "Managed by Terraform"
  tags        = ["terraform", "base"]
  template    = true
  pool_id     = var.pool_id

  machine = "q35"
  bios    = "ovmf"

  agent {
    # read 'Qemu guest agent' section, change to true only when ready
    enabled = true
  }

  cpu {
    cores = 2
    type  = "host" # recommended for modern CPUs
  }

  memory {
    dedicated = 2048
    floating  = 0 # set equal to dedicated to enable ballooning
  }

  disk {
    interface    = "virtio1"
    file_format  = "raw"
    size         = 10
    datastore_id = local.image_datastore[var.node_name]
  }

  disk {
    interface    = "virtio0"
    import_from  = proxmox_virtual_environment_download_file.boot_image.id
    datastore_id = local.image_datastore[var.node_name]
    size         = 30
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


  network_device {
    bridge = "vmbr0"
  }

  operating_system {
    type = "l26"
  }

  initialization {
    datastore_id      = local.image_datastore[var.node_name]
    interface         = "sata0"
    user_data_file_id = proxmox_virtual_environment_file.user_data.id

    ip_config {
      ipv4 {
        address = var.base_ip_config.ipv4.address
        gateway = var.base_ip_config.ipv4.gateway
      }
      ipv6 {
        address = var.base_ip_config.ipv6.address
        gateway = var.base_ip_config.ipv6.gateway
      }
    }
    dns {
      servers = var.base_dns_servers
    }
  }
}
