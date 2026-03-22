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

provider "tls" {

}

provider "local" {

}

module "infra" {
  source = "./modules/infra"

  cluster_name = var.cluster_name
  local_repo_vm_enabled = true
  local_repo_vm_ipv4_address = "192.168.0.50/24"
  local_repo_vm_ipv4_gateway = "192.168.0.1"

  providers = {
    proxmox   = proxmox
    talos     = talos
    cloudinit = cloudinit
    random    = random
    tls       = tls
    local     = local
  }
}
