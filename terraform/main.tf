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
  tags    = ["talos", "kubernetes"]
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

  boot_image       = "https://repo.almalinux.org/almalinux/10/cloud/x86_64/images/AlmaLinux-10-GenericCloud-latest.x86_64.qcow2"
  base_dns_servers = ["1.1.1.1"]
  base_ip_config = {
    ipv4 = {
      address = "192.168.0.22/24"
      gateway = "192.168.0.1"
    }
    ipv6 = {
      address = "auto"
    }
  }
  cloud_init_datastore_id = proxmox_virtual_environment_storage_directory.cloud_config_store.id
  user_data               = local.base_user_data_file
  user_data_file_name     = "base_user_data.yaml"
  pool_id                 = module.bootstrap_pool.pool_id
  node_name               = local.target_node
  tags                    = ["base", "almalinux"]
}

resource "proxmox_virtual_environment_file" "dns_user_data" {
  datastore_id = proxmox_virtual_environment_storage_directory.cloud_config_store.id
  node_name    = local.target_node

  source_raw {
    data      = local.dns_user_data_file
    file_name = "dns_user_data.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "dns_server" {
  node_name   = local.target_node
  name        = "dns-server"
  description = "Managed by Terraform"
  tags        = ["terraform", "dns", "almalinux"]
  pool_id     = module.bootstrap_pool.pool_id

  clone {
    vm_id = module.base_template.vm_id
    full  = false
    node_name = local.target_node
  }

  initialization {
    datastore_id      = local.image_datastore[local.target_node]
    interface         = "sata0"
    user_data_file_id = proxmox_virtual_environment_file.dns_user_data.id

    ip_config {
      ipv4 {
        address = "192.168.0.53/24"
        gateway = "192.168.0.1"
      }
      ipv6 {
        address = "auto"
      }
    }
    dns {
      servers = ["1.1.1.1"]
    }
  }
}


# dns/ntp
# container registry



data "proxmox_virtual_environment_nodes" "available_nodes" {}

data "proxmox_virtual_environment_datastores" "avalible_datastores" {
  for_each  = toset(data.proxmox_virtual_environment_nodes.available_nodes.names)
  node_name = each.key
}

locals {
  node_datastores = {
    for node in toset(data.proxmox_virtual_environment_nodes.available_nodes.names) :
    node => data.proxmox_virtual_environment_datastores.avalible_datastores[node].datastores
  }
  image_datastore = {
    for node_name, datastores in local.node_datastores :
    node_name => [for ds in datastores : ds.id if ds.id == "local-zfs"][0]
  }
  target_node = data.proxmox_virtual_environment_nodes.available_nodes.names[0]
}
