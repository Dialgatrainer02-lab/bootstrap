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

  service_feature_gates = {
    local_mirror = true
    openbao      = false
  }

  service_network_subnet_cidr = "192.168.0.0/24"
  service_network_gateway     = "192.168.0.1"

  providers = {
    proxmox   = proxmox
    talos     = talos
    cloudinit = cloudinit
    random    = random
    tls       = tls
    local     = local
  }
}
