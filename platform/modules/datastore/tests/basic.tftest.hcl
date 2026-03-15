provider "proxmox" {
  insecure = true
}

run "basic_plan" {
  command = plan

  variables {
    name    = "test-dir"
    type    = "directory"
    path    = "/mnt/pve/test-dir"
    content = ["rootdir"]
  }

  assert {
    condition     = proxmox_virtual_environment_storage_directory.this[0].id == "test-dir"
    error_message = "Expected storage_id to match the datastore name."
  }

  assert {
    condition     = proxmox_virtual_environment_storage_directory.this[0].path == "/mnt/pve/test-dir"
    error_message = "Expected directory path to pass through."
  }
}
