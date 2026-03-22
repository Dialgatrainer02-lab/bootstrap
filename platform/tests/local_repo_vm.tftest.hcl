provider "proxmox" {
  insecure = true
}


run "plan_local_repo_vm" {
  module {
    source = "./modules/local_repo_vm"
  }

  command = plan

  variables {
    name                  = "repo-1"
    node_name             = "pve-01"
    datastore_id          = "local-lvm"
    snippets_datastore_id = "local"
    boot_image_id         = "local:iso/AlmaLinux-10-GenericCloud-latest.x86_64.qcow2.img"
    boot_image_kind       = "disk"
    repo_url              = "https://example.invalid/repo.git"
    ssh_authorized_keys   = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMockKeyForTests user@host"]
    tags                  = ["local-repo"]
  }

  assert {
    condition     = proxmox_virtual_environment_file.cloud_init_user_data.datastore_id == "local"
    error_message = "Expected cloud-init user-data snippet to be uploaded to snippets_datastore_id."
  }


  assert {
    condition     = module.vm.vm.disk[0].file_id == "local:iso/AlmaLinux-10-GenericCloud-latest.x86_64.qcow2.img"
    error_message = "Expected VM to use the provided boot_image_id."
  }
}

run "snippets_datastore_apply" {
  module {
    source = "./modules/datastore"
  }

  command = apply

  variables {
    name    = "vm-snippets"
    type    = "directory"
    path    = "/mnt/pve/vm-snippets"
    content = ["snippets"]
  }
}
