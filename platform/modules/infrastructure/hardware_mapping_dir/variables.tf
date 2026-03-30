variable "name" {
  type        = string
  description = "Name of the Proxmox hardware directory mapping."
}

variable "comment" {
  type        = string
  description = "Optional comment for the hardware directory mapping."
  default     = null
}

variable "map" {
  type = set(object({
    node = string
    path = string
  }))
  description = "Directory mappings keyed by node name."

  validation {
    condition     = length(var.map) > 0
    error_message = "map must contain at least one node/path mapping."
  }
}
