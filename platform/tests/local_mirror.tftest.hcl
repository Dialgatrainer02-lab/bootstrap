provider "proxmox" {
  insecure = true
}


run "plan_local_repo_vm" {
  module {
    source = "./modules/local_mirror"
  }

  command = plan

  variables {
    name                      = "repo-1"
    node_name                 = "pve-01"
    datastore_id              = "local-lvm"
    snippets_datastore_id     = "local"
    boot_image_id             = "local:iso/AlmaLinux-10-GenericCloud-latest.x86_64.qcow2.img"
    boot_image_kind           = "disk"
    ssh_authorized_keys       = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMockKeyForTests user@host"]
    tags                      = ["local-repo"]
    virtiofs_dir_mapping_path = "/mnt/pve/repo-1-share"
    virtiofs = {
      mapping      = "repo-share"
      cache        = "always"
      direct_io    = true
      expose_acl   = true
      expose_xattr = true
    }
  }

  assert {
    condition     = proxmox_virtual_environment_file.cloud_init_user_data.datastore_id == "local"
    error_message = "Expected cloud-init user-data snippet to be uploaded to snippets_datastore_id."
  }


  assert {
    condition     = module.vm.vm.disk[0].file_id == "local:iso/AlmaLinux-10-GenericCloud-latest.x86_64.qcow2.img"
    error_message = "Expected VM to use the provided boot_image_id."
  }

  assert {
    condition     = module.vm.vm.virtiofs[0].mapping == "repo-share"
    error_message = "Expected local_mirror virtiofs.mapping to pass through to the VM module."
  }

  assert {
    condition     = module.virtiofs_dir_mapping[0].name == "repo-share"
    error_message = "Expected local_mirror to create a Proxmox directory mapping for virtiofs."
  }

  assert {
    condition     = contains([for entry in module.virtiofs_dir_mapping[0].map : entry.path], "/mnt/pve/repo-1-share")
    error_message = "Expected local_mirror directory mapping path to pass through."
  }

  assert {
    condition     = module.vm.vm.virtiofs[0].cache == "always"
    error_message = "Expected local_mirror virtiofs.cache to pass through to the VM module."
  }
}
