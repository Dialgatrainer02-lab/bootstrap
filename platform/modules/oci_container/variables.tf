variable "name" {
  type        = string
  description = "Logical name used for hostname defaults."
}

variable "node_name" {
  type        = string
  description = "Proxmox node name to host the container."
}

variable "image_ref" {
  type        = string
  description = "OCI image reference (e.g., docker.io/library/ubuntu:latest)."
}

variable "image_file_name" {
  type        = string
  description = "Optional file name for the pulled OCI image (stored as .tar)."
  default     = null
}

variable "oci_overwrite" {
  type        = bool
  description = "If true, replace the image when the size has changed."
  default     = true
}

variable "oci_overwrite_unmanaged" {
  type        = bool
  description = "If true, replace an existing unmanaged image with the same name."
  default     = false
}

variable "oci_upload_timeout" {
  type        = number
  description = "OCI image pull timeout in seconds."
  default     = 600
}

variable "image_datastore_id" {
  type        = string
  description = "Datastore to store the OCI image."
}

variable "datastore_id" {
  type        = string
  description = "Datastore to store the container root disk."
}

variable "vm_id" {
  type        = number
  description = "Optional Proxmox VM/CT ID. Leave null for auto-assignment."
  default     = null
}

variable "pool_id" {
  type        = string
  description = "Optional Proxmox pool ID to assign the container."
  default     = null
}

variable "cpu_cores" {
  type        = number
  description = "Number of CPU cores."
  default     = 1
}

variable "memory_mb" {
  type        = number
  description = "Dedicated memory in MB."
  default     = 1024
}

variable "disk_size_gb" {
  type        = number
  description = "Root disk size in GB."
  default     = 8
}

variable "network_bridge" {
  type        = string
  description = "Bridge name for the primary network interface."
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

variable "hostname" {
  type        = string
  description = "Optional hostname override. Defaults to the logical name."
  default     = null
}

variable "ssh_authorized_keys" {
  type        = list(string)
  description = "SSH public keys for the default user account."
  default     = []
}

variable "root_password" {
  type        = string
  description = "Root password for the default user account."
  default     = null
  sensitive   = true
}

variable "unprivileged" {
  type        = bool
  description = "Run the container unprivileged."
  default     = true
}

variable "enable_nesting" {
  type        = bool
  description = "Enable nesting for the container."
  default     = false
}

variable "tags" {
  type        = list(string)
  description = "Tags applied to the container."
  default     = []
}

variable "env" {
  type        = map(string)
  description = "Environment variables for the OCI workload."
  default     = {}
}

variable "mount_points" {
  type = list(object({
    path          = string
    volume        = string
    size          = optional(string)
    read_only     = optional(bool)
    backup        = optional(bool)
    replicate     = optional(bool)
    shared        = optional(bool)
    quota         = optional(bool)
    acl           = optional(bool)
    mount_options = optional(list(string))
  }))
  description = "Additional container mount points. Use a host path in volume for bind mounts."
  default     = []
}
