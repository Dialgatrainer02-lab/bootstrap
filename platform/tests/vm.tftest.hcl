provider "proxmox" {
  insecure = true
}

run "plan_with_boot_image_id" {
  module {
    source = "./modules/vm"
  }

  command = plan

  variables {
    name                = "vm-1"
    node_name           = "pve-01"
    datastore_id        = "local-lvm"
    vm_id               = 201
    machine             = "q35"
    efi_disk_type       = "4m"
    pre_enrolled_keys   = true
    cpu_cores           = 2
    cpu_type            = "host"
    memory_mb           = 2048
    disk_size_gb        = 20
    network_bridge      = "vmbr0"
    boot_image_id       = "local:iso/ubuntu-24.04.iso"
    ipv4_address        = "dhcp"
    dns_servers         = ["1.1.1.1"]
    dns_domain          = "lab.local"
    ssh_authorized_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMockKeyForTests user@host"]
    user_password       = "test-password"
    tags                = ["test"]

    extra_disks = [
      {
        size_gb = 5
      }
    ]

    network_devices = [
      {
        bridge = "vmbr0"
      },
      {
        bridge  = "vmbr1"
        vlan_id = 100
      }
    ]
  }

  assert {
    condition     = proxmox_virtual_environment_vm.this.tags[0] == "test"
    error_message = "Expected tags to be set on the VM."
  }

  assert {
    condition     = proxmox_virtual_environment_vm.this.machine == "q35"
    error_message = "Expected machine type to be set on the VM."
  }

  assert {
    condition     = proxmox_virtual_environment_vm.this.efi_disk[0].datastore_id == "local-lvm"
    error_message = "Expected EFI state disk to be stored on the VM datastore."
  }

  assert {
    condition     = proxmox_virtual_environment_vm.this.efi_disk[0].type == "4m"
    error_message = "Expected EFI disk type to pass through to the VM."
  }

  assert {
    condition     = proxmox_virtual_environment_vm.this.efi_disk[0].pre_enrolled_keys == true
    error_message = "Expected pre_enrolled_keys to pass through to the VM."
  }

  assert {
    condition     = proxmox_virtual_environment_vm.this.cpu[0].type == "host"
    error_message = "Expected cpu.type to pass through to the VM."
  }

  assert {
    condition     = proxmox_virtual_environment_vm.this.cdrom[0].file_id == "local:iso/ubuntu-24.04.iso"
    error_message = "Expected boot image id to be used for the VM cdrom."
  }

  assert {
    condition     = length(proxmox_virtual_environment_vm.this.disk) == 2
    error_message = "Expected primary disk plus one extra disk."
  }

  assert {
    condition     = proxmox_virtual_environment_vm.this.disk[1].interface == "scsi1"
    error_message = "Expected extra disk interface to default to scsi1."
  }

  assert {
    condition     = length(proxmox_virtual_environment_vm.this.network_device) == 2
    error_message = "Expected two network devices to be configured on the VM."
  }

  assert {
    condition     = proxmox_virtual_environment_vm.this.network_device[1].vlan_id == 100
    error_message = "Expected vlan_id to pass through to the second network device."
  }

  assert {
    condition     = length(proxmox_virtual_environment_download_file.boot) == 0
    error_message = "Expected no download when boot_image_id is provided."
  }
}

run "plan_with_boot_image_url" {
  module {
    source = "./modules/vm"
  }

  command = plan

  variables {
    name                    = "vm-2"
    node_name               = "pve-01"
    datastore_id            = "local-lvm"
    boot_image_datastore_id = "local"
    boot_image_url          = "https://tinycorelinux.net/14.x/x86_64/release/TinyCorePure64-14.0.iso"
    boot_image_file_name    = "tinycore-14.0.iso"
    boot_image_content_type = "iso"
    cpu_cores               = 1
    memory_mb               = 1024
    disk_size_gb            = 10
    network_bridge          = "vmbr0"
    ipv4_address            = "dhcp"
    tags                    = ["url"]
  }

  assert {
    condition     = length(proxmox_virtual_environment_download_file.boot) == 1
    error_message = "Expected boot image to be downloaded when boot_image_url is provided."
  }

  assert {
    condition     = proxmox_virtual_environment_download_file.boot[0].url == "https://tinycorelinux.net/14.x/x86_64/release/TinyCorePure64-14.0.iso"
    error_message = "Expected download URL to match the requested boot image."
  }


}

run "basic_apply" {
  module {
    source = "./modules/vm"
  }

  command = apply

  variables {
    name                    = "vm-apply-1"
    node_name               = "pve"
    datastore_id            = "local-zfs"
    boot_image_datastore_id = "local"
    boot_image_url          = "http://www.tinycorelinux.net/17.x/x86_64/release/TinyCorePure64-current.iso"
    boot_image_content_type = "iso"
    boot_image_file_name    = "vm-apply-tinycore-latest.iso"

    cpu_cores      = 1
    cpu_type       = "host"
    memory_mb      = 1024
    disk_size_gb   = 10
    network_bridge = "vmbr0"
    ipv4_address   = "dhcp"
    tags           = ["apply-test"]
  }

  assert {
    condition     = proxmox_virtual_environment_vm.this.node_name == "pve"
    error_message = "Expected node_name to pass through to the VM."
  }

  assert {
    condition     = proxmox_virtual_environment_vm.this.disk[0].datastore_id == "local-zfs"
    error_message = "Expected datastore_id to pass through to the primary VM disk."
  }

  assert {
    condition     = proxmox_virtual_environment_download_file.boot[0].datastore_id == "local"
    error_message = "Expected boot image to download into the requested datastore."
  }

  assert {
    condition     = proxmox_virtual_environment_vm.this.cdrom[0].file_id == proxmox_virtual_environment_download_file.boot[0].id
    error_message = "Expected VM to use the downloaded boot image."
  }
}
