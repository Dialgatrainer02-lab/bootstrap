
# Auto-discover available Proxmox nodes for downstream modules.
data "proxmox_virtual_environment_nodes" "discovered" {}

# Boilerplate module for Proxmox + Talos + Cloud-Init.
# Add resources here once you define your node schema.

# Example layout guidance:
# - Proxmox VM resources (bpg/proxmox)
# - cloud-init user-data templates (hashicorp/cloudinit)
# - Talos machine config + apply steps (siderolabs/talos)
  