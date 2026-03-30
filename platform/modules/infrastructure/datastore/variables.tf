variable "name" {
  type        = string
  description = "Datastore name (storage ID in Proxmox)."
}

variable "type" {
  type        = string
  description = "Datastore type. Only 'directory' is supported right now."
  default     = "directory"

  validation {
    condition     = var.type == "directory"
    error_message = "Only 'directory' datastore type is supported."
  }
}

variable "pool_id" {
  type    = string
  default = null
}

variable "attach_to_pool" {
  type        = bool
  description = "Whether to attach this datastore to a Proxmox resource pool."
  default     = true
}
variable "path" {
  type        = string
  description = "Filesystem path for the directory storage."
}

variable "content" {
  type        = list(string)
  description = "Allowed content types for the datastore."
  default     = ["rootdir"]
}

variable "nodes" {
  type        = list(string)
  description = "Nodes where this datastore is available."
  default     = []
}

variable "shared" {
  type        = bool
  description = "Whether the datastore is shared between nodes."
  default     = false
}

variable "disable" {
  type        = bool
  description = "Whether the datastore is disabled."
  default     = false
}
