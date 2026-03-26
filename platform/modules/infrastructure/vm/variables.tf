variable "name" {
  type        = string
  description = "Logical name used for hostname defaults."
}

variable "node_name" {
  type        = string
  description = "Proxmox node name to host the VM."
}

variable "datastore_id" {
  type        = string
  description = "Datastore to store the VM disk."
}

variable "boot_image_id" {
  type        = string
  description = "Existing Proxmox file id for the boot image (ISO or disk image)."
  default     = null
}

variable "boot_image_kind" {
  type        = string
  description = "How the boot_image_id/URL is used: iso mounts as cdrom; disk attaches as the primary disk."
  default     = "iso"

  validation {
    condition     = contains(["iso", "disk"], var.boot_image_kind)
    error_message = "boot_image_kind must be one of: iso, disk."
  }
}

variable "boot_image_url" {
  type        = string
  description = "URL to download the boot image into the datastore."
  default     = null
}

variable "boot_image_file_name" {
  type        = string
  description = "Optional file name for the downloaded boot image."
  default     = null
}

variable "boot_image_datastore_id" {
  type        = string
  description = "Datastore to store the downloaded boot image. Defaults to datastore_id when unset."
  default     = null
}

variable "boot_image_content_type" {
  type        = string
  description = "Content type for the downloaded boot image."
  default     = "iso"
}

variable "boot_image_overwrite" {
  type        = bool
  description = "If true, replace the downloaded boot image when the size has changed."
  default     = true
}

variable "boot_image_overwrite_unmanaged" {
  type        = bool
  description = "If true, replace an existing unmanaged image with the same name."
  default     = false
}

variable "pre_enrolled_keys" {
  type        = bool
  description = "whether to pre enroll microsoft keys into the uefi database"
  default     = false
}

variable "machine" {
  type        = string
  description = "QEMU machine type (e.g., q35)."
  default     = "q35"
}

variable "bios" {
  type        = string
  description = "vm bios tytpe"
  default     = "ovmf"
}

variable "guest_agent_enabled" {
  type        = bool
  description = "Whether to enable the Proxmox QEMU guest agent for this VM."
  default     = true
}

variable "stop_on_destroy" {
  type        = bool
  description = "Whether Terraform should stop the VM before destroy. Defaults to true when guest_agent_enabled is false."
  default     = null
}

variable "efi_disk_type" {
  type        = string
  description = "EFI disk type/size."
  default     = "4m"
}

variable "cloud_init_snippets_datastore_id" {
  type        = string
  description = "Datastore to store cloud-init snippets (content_type=snippets)."
  default     = null
}

variable "cloud_init_interface" {
  type        = string
  description = "Disk bus slot for the cloud-init drive (e.g., sata1, scsi1, ide2, virtio1)."
  default     = "sata1"

  validation {
    condition     = can(regex("^(ide|sata|scsi|virtio)[0-9]+$", var.cloud_init_interface))
    error_message = "cloud_init_interface must match a valid bus slot, such as sata1, scsi1, ide2, or virtio1."
  }
}

variable "cloud_init_user_data" {
  type        = string
  description = "Cloud-init user-data content. Use file(\"path\") at the callsite to pass a local file."
  default     = null
}

variable "cloud_init_user_data_file_id" {
  type        = string
  description = "Existing Proxmox snippet file id to use as cloud-init user-data."
  default     = null
}

variable "cloud_init_user_data_file_name" {
  type        = string
  description = "Optional file name for uploaded cloud-init user-data snippet."
  default     = null
}

variable "cloud_init_meta_data" {
  type        = string
  description = "Cloud-init meta-data content. Use file(\"path\") at the callsite to pass a local file."
  default     = null
}

variable "cloud_init_meta_data_file_id" {
  type        = string
  description = "Existing Proxmox snippet file id to use as cloud-init meta-data."
  default     = null
}

variable "cloud_init_meta_data_file_name" {
  type        = string
  description = "Optional file name for uploaded cloud-init meta-data snippet."
  default     = null
}

variable "cloud_init_network_data" {
  type        = string
  description = "Cloud-init network-data content. Use file(\"path\") at the callsite to pass a local file."
  default     = null
}

variable "cloud_init_network_data_file_id" {
  type        = string
  description = "Existing Proxmox snippet file id to use as cloud-init network-data."
  default     = null
}

variable "cloud_init_network_data_file_name" {
  type        = string
  description = "Optional file name for uploaded cloud-init network-data snippet."
  default     = null
}

variable "vm_id" {
  type        = number
  description = "Optional Proxmox VM ID. Leave null for auto-assignment."
  default     = null
}

variable "pool_id" {
  type        = string
  description = "Optional Proxmox pool ID to assign the VM."
  default     = null
}

variable "cpu_cores" {
  type        = number
  description = "Number of CPU cores."
  default     = 2
}

variable "cpu_type" {
  type        = string
  description = "CPU type/model exposed to the guest (e.g., host, x86-64-v2)."
  default     = "host"
}

variable "cpu_flags" {
  type        = list(string)
  description = "Optional list of CPU flags to expose to the guest."
  default     = []
}

variable "memory_mb" {
  type        = number
  description = "Dedicated memory in MB."
  default     = 2048
}

variable "disk_size_gb" {
  type        = number
  description = "Primary disk size in GB."
  default     = 20
}

variable "disk_interface" {
  type        = string
  description = "Disk bus type used for primary and default extra disks (ide, sata, scsi, virtio)."
  default     = "scsi"

  validation {
    condition     = contains(["ide", "sata", "scsi", "virtio"], var.disk_interface)
    error_message = "disk_interface must be one of: ide, sata, scsi, virtio."
  }
}

variable "disk_file_format" {
  type        = string
  description = "Disk image format for VM disks."
  default     = "raw"

  validation {
    condition     = contains(["raw", "qcow2", "vmdk"], var.disk_file_format)
    error_message = "disk_file_format must be one of: raw, qcow2, vmdk."
  }
}

variable "extra_disks" {
  type = list(object({
    datastore_id = optional(string)
    size_gb      = number
    interface    = optional(string)
  }))
  description = "Additional VM disks. If interface is omitted, disks are assigned sequential scsi slots (scsi1, scsi2, ...)."
  default     = []
}

variable "network_bridge" {
  type        = string
  description = "Bridge name for the primary network device."
  default     = "vmbr0"
}

variable "network_devices" {
  type = list(object({
    bridge      = string
    model       = optional(string)
    vlan_id     = optional(number)
    mac_address = optional(string)
    firewall    = optional(bool)
  }))
  description = "Network devices for the VM. If unset/empty, a single device is created using network_bridge."
  default     = []
}

variable "ipv4_address" {
  type        = string
  description = "IPv4 address or 'dhcp'."
  default     = "dhcp"
}

variable "ipv4_gateway" {
  type        = string
  description = "IPv4 gateway address."
  default     = null
}

variable "dns_servers" {
  type        = list(string)
  description = "DNS server IP addresses."
  default     = []
}

variable "dns_domain" {
  type        = string
  description = "DNS search domain."
  default     = null
}

variable "ssh_authorized_keys" {
  type        = list(string)
  description = "SSH public keys for the default user account."
  default     = []
}

variable "user_password" {
  type        = string
  description = "Password for the default user account."
  default     = null
  sensitive   = true
}

variable "tags" {
  type        = list(string)
  description = "Tags applied to the VM."
  default     = []
}

variable "os_type" {
  type        = string
  description = "Guest OS type (e.g., l26 for Linux)."
  default     = "l26"
}

variable "migrate" {
  type        = bool
  description = "Whether to migrate the VM when node_name changes instead of recreating."
  default     = true
}
