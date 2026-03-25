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
  address         = module.infra.openbao_api_address
  skip_tls_verify = true
  skip_get_vault_version = true

  auth_login_userpass {
    username = module.infra.openbao_admin_username
    password = module.infra.openbao_initial_admin_password
  }
}

module "infra" {
  source = "./modules/infra"

  cluster_name = var.cluster_name

  service_feature_gates = {
    local_mirror = true
    openbao      = true
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
