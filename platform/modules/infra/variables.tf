variable "cluster_name" {
  type        = string
  description = "Logical name for this platform/cluster."
}

variable "snippets_datastore_name" {
  type        = string
  description = "Proxmox storage ID for the shared snippets datastore."
  default     = null
}

variable "snippets_datastore_path" {
  type        = string
  description = "Filesystem path for the shared snippets datastore."
  default     = null
}

variable "images_datastore_name" {
  type        = string
  description = "Proxmox storage ID for the shared images datastore."
  default     = null
}

variable "images_datastore_path" {
  type        = string
  description = "Filesystem path for the shared images datastore."
  default     = null
}

variable "vm_template_url" {
  type        = string
  description = "URL to download a reusable VM template/boot image into the images datastore."
  default     = "https://repo.almalinux.org/almalinux/10/cloud/x86_64/images/AlmaLinux-10-GenericCloud-latest.x86_64.qcow2"
}

variable "vm_template_file_name" {
  type        = string
  description = "File name for the downloaded VM template/boot image."
  default     = "AlmaLinux-10-GenericCloud-latest.x86_64.qcow2.img"
}

variable "vm_template_content_type" {
  type        = string
  description = "Proxmox content type for the downloaded VM template/boot image."
  default     = "iso"
}

variable "vm_template_kind" {
  type        = string
  description = "How the downloaded vm_template_file_id should be used by default."
  default     = "disk"

  validation {
    condition     = contains(["iso", "disk"], var.vm_template_kind)
    error_message = "vm_template_kind must be one of: iso, disk."
  }
}

variable "vm_template_overwrite" {
  type        = bool
  description = "If true, replace the template when the size has changed."
  default     = true
}

variable "vm_template_overwrite_unmanaged" {
  type        = bool
  description = "If true, replace an existing unmanaged template with the same name."
  default     = false
}

variable "local_repo_vm_enabled" {
  type        = bool
  description = "If true, create the local repo VM via the local_repo_vm module."
  default     = false
}

variable "local_repo_vm_name" {
  type        = string
  description = "VM name for the local repo VM."
  default     = "local-repo"
}

variable "local_repo_vm_vm_id" {
  type        = number
  description = "Optional explicit VM ID for the local repo VM."
  default     = null
}

variable "local_repo_vm_datastore_id" {
  type        = string
  description = "Datastore for the local repo VM disks. Defaults to the images datastore when unset."
  default     = null
}

variable "local_repo_vm_cpu_cores" {
  type        = number
  description = "CPU cores for the local repo VM."
  default     = 2
}

variable "local_repo_vm_cpu_type" {
  type        = string
  description = "CPU type for the local repo VM."
  default     = null
}

variable "local_repo_vm_memory_mb" {
  type        = number
  description = "Memory for the local repo VM."
  default     = 2048
}

variable "local_repo_vm_disk_size_gb" {
  type        = number
  description = "Primary disk size for the local repo VM."
  default     = 20
}

variable "local_repo_vm_network_bridge" {
  type        = string
  description = "Bridge for the local repo VM."
  default     = "vmbr0"
}

variable "local_repo_vm_ipv4_address" {
  type        = string
  description = "IPv4 address or 'dhcp' for the local repo VM."
  default     = "dhcp"
}

variable "local_repo_vm_ipv4_gateway" {
  type        = string
  description = "IPv4 gateway for the local repo VM."
  default     = null
}

variable "local_repo_vm_dns_servers" {
  type        = list(string)
  description = "DNS servers for the local repo VM."
  default     = []
}

variable "local_repo_vm_dns_domain" {
  type        = string
  description = "DNS search domain for the local repo VM."
  default     = null
}

