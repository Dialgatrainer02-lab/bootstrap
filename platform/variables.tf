variable "cluster_name" {
  type        = string
  description = "Logical name for this platform/cluster."
}

variable "nodes" {
  type        = map(any)
  description = "Node definitions consumed by the infra module."
  default     = {}
}

variable "enable_examples" {
  type        = bool
  description = "Enable example resources inside the infra module."
  default     = false
}
