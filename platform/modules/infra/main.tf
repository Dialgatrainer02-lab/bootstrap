locals {
  example_enabled = var.enable_examples
}

# Boilerplate module for Proxmox + Talos + Cloud-Init.
# Add resources here once you define your node schema.

# Example layout guidance:
# - Proxmox VM resources (bpg/proxmox)
# - cloud-init user-data templates (hashicorp/cloudinit)
# - Talos machine config + apply steps (siderolabs/talos)
