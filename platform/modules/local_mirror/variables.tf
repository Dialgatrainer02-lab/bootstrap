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

variable "artifacts_datastore_id" {
  type        = string
  description = "Datastore to store local mirror artifacts (content_type=snippets)."
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

variable "repo_disk_device" {
  type        = string
  description = "Optional explicit block device path to format/mount for repo storage (for example /dev/sdb). If unset, the disk is selected by packages_disk_size_gb."
  default     = null
}

variable "repos_archive_file_name" {
  type        = string
  description = "File name of the prebuilt mirror archive exposed via virtiofs."
  default     = "almalinux-repos.tar.gz"

  validation {
    condition     = trimspace(var.repos_archive_file_name) != ""
    error_message = "repos_archive_file_name must not be empty."
  }
}

variable "repos_archive_source_path" {
  type        = string
  description = "Local filesystem path to the prebuilt mirror archive to upload to the artifacts datastore."

  validation {
    condition     = trimspace(var.repos_archive_source_path) != ""
    error_message = "repos_archive_source_path must not be empty."
  }
}

variable "virtiofs" {
  type = object({
    mapping      = string
    cache        = optional(string)
    direct_io    = optional(bool, false)
    expose_acl   = optional(bool)
    expose_xattr = optional(bool, true)
  })
  description = "Optional virtiofs shared directory mapping configuration to pass to the VM. direct_io defaults to false and expose_xattr defaults to true."
  default     = null

  validation {
    condition     = var.virtiofs == null ? true : try(var.virtiofs.cache == null || contains(["always", "auto", "metadata", "never"], var.virtiofs.cache), false)
    error_message = "virtiofs.cache must be one of: always, auto, metadata, never."
  }
}

variable "virtiofs_dir_mapping_name" {
  type        = string
  description = "Optional explicit name for the Proxmox directory hardware mapping. Defaults to <name>-virtiofs when virtiofs is enabled."
  default     = null
}

variable "virtiofs_dir_mapping_path" {
  type        = string
  description = "Optional host path for the directory mapping. Defaults to /mnt/pve/<mapping-name> when virtiofs is enabled."
  default     = null
}

variable "virtiofs_dir_mapping_comment" {
  type        = string
  description = "Optional comment for the Proxmox directory hardware mapping."
  default     = null
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
