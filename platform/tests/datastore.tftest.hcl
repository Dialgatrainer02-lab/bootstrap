provider "proxmox" {
  insecure = true
}

run "basic_plan" {
  module {
    source = "./modules/infrastructure/datastore"
  }

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

run "apply_plan" {
  module {
    source = "./modules/infrastructure/datastore"
  }

  command = apply

  variables {
    name    = "test-dir"
    type    = "directory"
    path    = "/mnt/pve/test-dir"
    content = ["snippets"]
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
