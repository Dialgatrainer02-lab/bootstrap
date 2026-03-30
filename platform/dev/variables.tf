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

variable "artifacts_datastore_name" {
  type        = string
  description = "Proxmox storage ID for the shared artifacts datastore."
  default     = null
}

variable "artifacts_datastore_path" {
  type        = string
  description = "Filesystem path for the shared artifacts datastore."
  default     = "/var/lib/artifacts"
}

variable "resource_pool_name" {
  type        = string
  description = "Proxmox resource pool ID used to group resources created by this module."
  default     = null
}

variable "resource_pool_comment" {
  type        = string
  description = "Optional comment for the Proxmox resource pool."
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

variable "local_mirror_repos_archive_path" {
  type        = string
  description = "Local filesystem path to the prebuilt local mirror archive produced by artifacts/mirror/reposync.sh."
  default     = null
}

variable "service_feature_gates" {
  type        = map(bool)
  description = "Feature gates for service VMs managed by infra (supported keys: local_mirror, openbao, local_registry)."
  default     = {}
}

variable "service_network_subnet_cidr" {
  type        = string
  description = "IPv4 subnet CIDR used for service VM addresses (for example 192.168.0.0/24)."

  validation {
    condition     = can(cidrhost(var.service_network_subnet_cidr, 1))
    error_message = "service_network_subnet_cidr must be a valid CIDR block."
  }
}

variable "service_network_gateway" {
  type        = string
  description = "IPv4 gateway used by service VMs."
}


variable "service_dns_domain" {
  type        = string
  description = "DNS search domain used by service VMs."
  default     = null
}
