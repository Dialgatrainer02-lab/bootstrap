variable "talos_version" {
  type        = string
  default     = "v1.12.3"
  description = "talos version to use"
}

variable "talos_ip_config" {
  description = "ip config for vm"
  type = object({
    ipv4 = object({
      gateway = optional(string)
      address = string
    })
    ipv6 = object({
      gateway = optional(string)
      address = string
    })
  })
}

variable "talos_dns_servers" {
  type        = list(string)
  description = "dns servers for the talos machine"
  default     = ["1.1.1.1"]
}

variable "pool_id" {
  type     = string
  nullable = true
  default  = null
}

variable "node_name" {
  type = string
}

variable "tags" {
  description = "additional tags to apply to the talos vm; 'terraform' is always included"
  type        = list(string)
  default     = []
}
