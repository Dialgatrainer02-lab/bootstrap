provider "proxmox" {
  # Configure via environment variables or explicit arguments.
}

provider "talos" {
  # Configure via environment variables or explicit arguments.
}

provider "cloudinit" {
  # This provider typically needs no explicit configuration.
}

module "infra" {
  source = "./modules/infra"

  cluster_name    = var.cluster_name
  nodes           = var.nodes
  enable_examples = var.enable_examples

  providers = {
    proxmox  = proxmox
    talos    = talos
    cloudinit = cloudinit
  }
}
