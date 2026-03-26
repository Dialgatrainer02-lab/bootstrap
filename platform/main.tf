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

provider "local" {}

provider "vault" {
  address                = module.dev.openbao_api_address
  skip_tls_verify        = true
  vault_version_override = "1.13.0"

  auth_login_userpass {
    username = module.dev.openbao_admin_username
    password = module.dev.openbao_initial_admin_password
  }
}

module "dev" {
  source = "./dev"

  cluster_name = "dev"
  service_feature_gates = {
    local_mirror   = true
    openbao        = true
    local_registry = false
  }

  service_network_subnet_cidr = "192.168.0.0/24"
  service_network_gateway     = "192.168.0.1"
  service_dns_domain          = var.service_dns_domain

  providers = {
    proxmox   = proxmox
    talos     = talos
    cloudinit = cloudinit
    random    = random
    tls       = tls
    local     = local
  }
}
