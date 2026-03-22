locals {
  boot_image_datastore = coalesce(var.boot_image_datastore_id, var.datastore_id)
  use_boot_image_url   = var.boot_image_url != null
  use_boot_image_id    = var.boot_image_id != null
  boot_image_file_id   = coalesce(var.boot_image_id, try(proxmox_virtual_environment_download_file.boot[0].id, null))

  cloud_init_snippets_datastore_id = var.cloud_init_snippets_datastore_id
  cloud_init_user_data_file_id = try(coalesce(
    var.cloud_init_user_data_file_id,
    try(proxmox_virtual_environment_file.cloud_init_user_data[0].id, null),
  ), null)
  cloud_init_meta_data_file_id = try(coalesce(
    var.cloud_init_meta_data_file_id,
    try(proxmox_virtual_environment_file.cloud_init_meta_data[0].id, null),
  ), null)
  cloud_init_network_data_file_id = try(coalesce(
    var.cloud_init_network_data_file_id,
    try(proxmox_virtual_environment_file.cloud_init_network_data[0].id, null),
  ), null)

  network_devices = length(var.network_devices) > 0 ? var.network_devices : [
    {
      bridge = var.network_bridge
    }
  ]

  primary_disk = {
    datastore_id = var.datastore_id
    size_gb      = var.disk_size_gb
    interface    = "scsi0"
    file_id      = var.boot_image_kind == "disk" ? local.boot_image_file_id : null
  }

  extra_disks = [
    for idx, disk in var.extra_disks : {
      datastore_id = coalesce(try(disk.datastore_id, null), var.datastore_id)
      size_gb      = disk.size_gb
      interface    = coalesce(try(disk.interface, null), "scsi${idx + 1}")
    }
  ]

  disks = concat([local.primary_disk], local.extra_disks)
}

resource "proxmox_virtual_environment_file" "cloud_init_user_data" {
  count = var.cloud_init_user_data != null && var.cloud_init_user_data_file_id == null ? 1 : 0

  content_type = "snippets"
  datastore_id = local.cloud_init_snippets_datastore_id
  node_name    = var.node_name

  source_raw {
    file_name = coalesce(var.cloud_init_user_data_file_name, "${var.name}-user-data.yaml")
    data      = var.cloud_init_user_data
  }

  lifecycle {
    precondition {
      condition     = var.cloud_init_snippets_datastore_id != null
      error_message = "cloud_init_snippets_datastore_id must be set when providing cloud_init_user_data."
    }
  }
}

resource "proxmox_virtual_environment_file" "cloud_init_meta_data" {
  count = var.cloud_init_meta_data != null && var.cloud_init_meta_data_file_id == null ? 1 : 0

  content_type = "snippets"
  datastore_id = local.cloud_init_snippets_datastore_id
  node_name    = var.node_name

  source_raw {
    file_name = coalesce(var.cloud_init_meta_data_file_name, "${var.name}-meta-data.yaml")
    data      = var.cloud_init_meta_data
  }

  lifecycle {
    precondition {
      condition     = var.cloud_init_snippets_datastore_id != null
      error_message = "cloud_init_snippets_datastore_id must be set when providing cloud_init_meta_data."
    }
  }
}

resource "proxmox_virtual_environment_file" "cloud_init_network_data" {
  count = var.cloud_init_network_data != null && var.cloud_init_network_data_file_id == null ? 1 : 0

  content_type = "snippets"
  datastore_id = local.cloud_init_snippets_datastore_id
  node_name    = var.node_name

  source_raw {
    file_name = coalesce(var.cloud_init_network_data_file_name, "${var.name}-network-data.yaml")
    data      = var.cloud_init_network_data
  }

  lifecycle {
    precondition {
      condition     = var.cloud_init_snippets_datastore_id != null
      error_message = "cloud_init_snippets_datastore_id must be set when providing cloud_init_network_data."
    }
  }
}

resource "proxmox_virtual_environment_download_file" "boot" {
  count = local.use_boot_image_url ? 1 : 0

  node_name           = var.node_name
  datastore_id        = local.boot_image_datastore
  content_type        = var.boot_image_content_type
  url                 = var.boot_image_url
  file_name           = var.boot_image_file_name
  overwrite           = var.boot_image_overwrite
  overwrite_unmanaged = var.boot_image_overwrite_unmanaged
}

resource "proxmox_virtual_environment_vm" "this" {
  name      = var.name
  node_name = var.node_name
  vm_id     = var.vm_id
  pool_id   = var.pool_id
  tags      = var.tags

  machine = var.machine
  bios = var.bios
  operating_system {
    type = var.os_type
  }

  agent {
    enabled = var.guest_agent_enabled
  }

  efi_disk {
    datastore_id      = var.datastore_id
    type              = var.efi_disk_type
    pre_enrolled_keys = var.pre_enrolled_keys
  }

  tpm_state {
    datastore_id = var.datastore_id
  }

  cpu {
    cores = var.cpu_cores
    type  = var.cpu_type
  }

  memory {
    dedicated = var.memory_mb
  }

  dynamic "disk" {
    for_each = local.disks
    content {
      datastore_id = disk.value.datastore_id
      size         = disk.value.size_gb
      interface    = disk.value.interface
      file_id      = try(disk.value.file_id, null)
    }
  }

  dynamic "cdrom" {
    for_each = var.boot_image_kind == "iso" ? [true] : []
    content {
      file_id = local.boot_image_file_id
    }
  }

  dynamic "network_device" {
    for_each = local.network_devices
    content {
      bridge      = network_device.value.bridge
      model       = try(network_device.value.model, null)
      vlan_id     = try(network_device.value.vlan_id, null)
      mac_address = try(network_device.value.mac_address, null)
      firewall    = try(network_device.value.firewall, null)
    }
  }

  serial_device {}
  initialization {
    datastore_id = var.datastore_id
    interface = var.cloud_init_interface
    file_format = "raw"

    user_data_file_id    = local.cloud_init_user_data_file_id
    meta_data_file_id    = local.cloud_init_meta_data_file_id
    network_data_file_id = local.cloud_init_network_data_file_id

    ip_config {
      ipv4 {
        address = var.ipv4_address
        gateway = var.ipv4_gateway
      }
    }

    dns {
      domain  = var.dns_domain
      servers = var.dns_servers
    }

    user_account {
      keys     = var.ssh_authorized_keys
      password = var.user_password
    }
  }

  lifecycle {
    precondition {
      condition     = local.use_boot_image_id != local.use_boot_image_url
      error_message = "Exactly one of boot_image_id or boot_image_url must be set."
    }

    precondition {
      condition     = !(var.cloud_init_user_data != null && var.cloud_init_user_data_file_id != null)
      error_message = "Only one of cloud_init_user_data or cloud_init_user_data_file_id can be set."
    }

    precondition {
      condition     = !(var.cloud_init_meta_data != null && var.cloud_init_meta_data_file_id != null)
      error_message = "Only one of cloud_init_meta_data or cloud_init_meta_data_file_id can be set."
    }

    precondition {
      condition     = !(var.cloud_init_network_data != null && var.cloud_init_network_data_file_id != null)
      error_message = "Only one of cloud_init_network_data or cloud_init_network_data_file_id can be set."
    }
  }
}
