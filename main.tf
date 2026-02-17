# management cluster with talos

# generic template for pheriral services

# vms based on that template
module "bootstrap_pool" {
  source = "./modules/pool"

  pool_name    = "bootstrap"
  pool_comment = "testing"
}

module "management_cluster" {
  source  = "./modules/talos"
  pool_id = module.bootstrap_pool.pool_id
  talos_ip_config = {
    ipv4 = {
      address = "192.168.0.99/24"
      gateway = "192.168.0.1"
    }
    ipv6 = {
      address = "auto"
    }
  }
  node_name = local.target_node
}

module "base_template" {
  source = "./modules/base"

  boot_image       = "https://dl.rockylinux.org/pub/rocky/10/images/x86_64/Rocky-10-GenericCloud-Base.latest.x86_64.qcow2"
  base_dns_servers = ["1.1.1.1"]
  base_ip_config = {
    ipv4 = {
      address = "dhcp"
    }
    ipv6 = {
      address = "auto"
    }
  }
  user_data = local.base_user_data_file
  pool_id   = module.bootstrap_pool.pool_id
  node_name = local.target_node
}


# dns/ntp
# container registry



data "proxmox_virtual_environment_nodes" "available_nodes" {}

data "proxmox_virtual_environment_datastores" "avalible_datastores" {
  for_each  = toset(data.proxmox_virtual_environment_nodes.available_nodes.names)
  node_name = each.key
}

locals {
  target_node = data.proxmox_virtual_environment_nodes.available_nodes.names[0]
}
