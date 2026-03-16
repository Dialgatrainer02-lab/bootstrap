provider "proxmox" {
  insecure = true
}

run "basic_plan" {
  module {
    source = "./modules/oci_container"
  }

  command = plan


  variables {
    name                = "app-1"
    node_name           = "pve-01"
    image_datastore_id  = "local"
    datastore_id        = "local-lvm"
    image_ref           = "docker.io/library/ubuntu:24.04"
    image_file_name     = "ubuntu-24.04.tar"
    vm_id               = 101
    pool_id             = "lab"
    cpu_cores           = 2
    memory_mb           = 2048
    disk_size_gb        = 16
    network_bridge      = "vmbr0"
    ipv4_address        = "dhcp"
    dns_servers         = ["1.1.1.1"]
    dns_domain          = "lab.local"
    ssh_authorized_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMockKeyForTests user@host"]
    root_password       = "test-password"
    unprivileged        = true
    enable_nesting      = true
    tags                = ["test"]
    env = {
      APP_ENV = "dev"
    }
    mount_points = [
      {
        path      = "/data"
        volume    = "test-vol-1"
        read_only = true
      }
    ]
  }


  assert {
    condition     = proxmox_virtual_environment_container.this.pool_id == "lab"
    error_message = "Expected pool_id to pass through to the container."
  }

  assert {
    condition     = proxmox_virtual_environment_container.this.environment_variables["APP_ENV"] == "dev"
    error_message = "Expected environment_variables to include APP_ENV."
  }

  assert {
    condition     = proxmox_virtual_environment_container.this.tags[0] == "test"
    error_message = "Expected tags to be set on the container."
  }

  assert {
    condition     = proxmox_virtual_environment_container.this.mount_point[0].path == "/data"
    error_message = "Expected bind mount to be configured on the container."
  }
}

run "basic_apply" {
  module {
    source = "./modules/oci_container"
  }

  command = apply


  variables {
    name               = "app-apply-1"
    node_name          = "pve"
    image_datastore_id = "local"
    datastore_id       = "local-zfs"
    image_ref          = "docker.io/library/ubuntu:24.04"
    image_file_name    = "ubuntu-24.04.tar"
    dns_servers        = ["1.1.1.1"]
    vm_id              = 300
    cpu_cores          = 1
    memory_mb          = 1024
    disk_size_gb       = 8
    network_bridge     = "vmbr0"
    ipv4_address       = "dhcp"
    unprivileged       = true
    tags               = ["apply-test"]
    env = {
      APP_ENV = "apply"
    }
  }

  assert {
    condition     = proxmox_virtual_environment_container.this.node_name == "pve"
    error_message = "Expected node_name to pass through to the container."
  }

  assert {
    condition     = proxmox_virtual_environment_container.this.disk[0].datastore_id == "local-zfs"
    error_message = "Expected datastore_id to pass through to the container disk."
  }
}
