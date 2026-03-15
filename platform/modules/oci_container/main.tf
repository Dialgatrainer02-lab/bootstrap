locals {
  hostname = coalesce(var.hostname, var.name)
}

# OCI-like container via Proxmox LXC templates.
resource "proxmox_virtual_environment_oci_image" "this" {
  node_name           = var.node_name
  datastore_id        = var.image_datastore_id
  reference           = var.image_ref
  file_name           = var.image_file_name
  overwrite           = var.oci_overwrite
  overwrite_unmanaged = var.oci_overwrite_unmanaged
  upload_timeout      = var.oci_upload_timeout
}

resource "proxmox_virtual_environment_container" "this" {
  node_name    = var.node_name
  vm_id        = var.vm_id
  pool_id      = var.pool_id
  tags         = var.tags
  unprivileged = var.unprivileged

  operating_system {
    template_file_id = proxmox_virtual_environment_oci_image.this.id
  }

  disk {
    datastore_id = var.datastore_id
    size         = var.disk_size_gb
  }

  cpu {
    cores = var.cpu_cores
  }

  memory {
    dedicated = var.memory_mb
  }

  network_interface {
    name = var.network_bridge
  }

  dynamic "mount_point" {
    for_each = var.mount_points
    content {
      path          = mount_point.value.path
      volume        = mount_point.value.volume
      size          = try(mount_point.value.size, null)
      read_only     = try(mount_point.value.read_only, null)
      backup        = try(mount_point.value.backup, null)
      replicate     = try(mount_point.value.replicate, null)
      shared        = try(mount_point.value.shared, null)
      quota         = try(mount_point.value.quota, null)
      acl           = try(mount_point.value.acl, null)
      mount_options = try(mount_point.value.mount_options, null)
    }
  }

  initialization {
    hostname = local.hostname

    ip_config {
      ipv4 {
        address = var.ipv4_address
        gateway = var.ipv4_gateway
      }
    }

    dns {
      domain = var.dns_domain
      servers = var.dns_servers
    }

    user_account {
      keys     = var.ssh_authorized_keys
      password = var.root_password
    }
  }

  environment_variables = var.env

  features {
    nesting = var.enable_nesting
  }
}
