variable "name" {
  type        = string
  description = "VM name."
}

variable "node_name" {
  type        = string
  description = "Proxmox node name to host the VM."
}

variable "datastore_id" {
  type        = string
  description = "Datastore to store the VM disks."
}

variable "snippets_datastore_id" {
  type        = string
  description = "Datastore to store cloud-init snippets (content_type=snippets). Typically provided by the infra module."
}

variable "boot_image_id" {
  type        = string
  description = "Boot image/template file id to use for the VM (typically downloaded by the infra module)."
}

variable "boot_image_kind" {
  type        = string
  description = "How boot_image_id is used: iso mounts as cdrom; disk attaches as the primary disk."
  default     = "disk"

  validation {
    condition     = contains(["iso", "disk"], var.boot_image_kind)
    error_message = "boot_image_kind must be one of: iso, disk."
  }
}

variable "pool_id" {
  type        = string
  description = "Optional Proxmox pool ID to assign the VM."
  default     = null
}

variable "vm_id" {
  type        = number
  description = "Optional Proxmox VM ID. Leave null for auto-assignment."
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

variable "packages_disk_size_gb" {
  type        = number
  description = "Size in GB of the secondary disk used to store mirrored packages."
  default     = 100
}

variable "network_bridge" {
  type        = string
  description = "Bridge name for the primary network device."
  default     = "vmbr0"
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

variable "cloud_init_user_data" {
  type        = string
  description = "Optional cloud-init user-data content. If unset, a default template is rendered."
  default     = null
}

variable "ssh_authorized_keys" {
  type        = list(string)
  description = "SSH public keys for the admin user in cloud-init."
  default     = []
}

variable "tags" {
  type        = list(string)
  description = "Tags applied to the VM."
  default     = []
}
