provider "proxmox" {
  insecure = true
}

run "basic_plan" {
  module {
    source = "./modules/infrastructure/hardware_mapping_dir"
  }

  command = plan

  variables {
    name    = "repo-share"
    comment = "Directory mapping for virtiofs"
    map = [
      {
        node = "pve-01"
        path = "/mnt/pve/repo-share"
      }
    ]
  }

  assert {
    condition     = proxmox_virtual_environment_hardware_mapping_dir.this.name == "repo-share"
    error_message = "Expected hardware mapping name to match the module input."
  }

  assert {
    condition     = contains([for entry in proxmox_virtual_environment_hardware_mapping_dir.this.map : entry.path], "/mnt/pve/repo-share")
    error_message = "Expected hardware mapping path to pass through."
  }
}
