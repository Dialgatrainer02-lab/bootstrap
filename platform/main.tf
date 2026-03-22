provider "proxmox" {
  insecure = true
}

provider "talos" {
  # Configure via environment variables or explicit arguments.
}

provider "cloudinit" {
  # This provider typically needs no explicit configuration.
}

provider "random" {

}

module "infra" {
  source = "./modules/infra"

  cluster_name = var.cluster_name
  local_repo_vm_enabled = true

  providers = {
    proxmox   = proxmox
    talos     = talos
    cloudinit = cloudinit
    random    = random
  }
}
