variable "pool_id" {
  type = string
}

variable "node_name" {
  type = string
}

variable "boot_image" {
  type        = string
  description = "boot image for the base vm to use (expecting rhel based)"
}

variable "base_dns_servers" {
  type    = list(string)
  default = ["1.1.1.1"]
}

variable "base_ip_config" {
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

variable "cloud_init_datastore_id" {
  description = "datastore id that supports snippets content type"
  type        = string
  default     = "cloud-config-store"
}

variable "user_data_file_name" {
  description = "file name to write the cloud-init snippet as"
  type        = string
  default     = "base_user_data.yaml"
}

variable "user_data" {
  description = "raw cloud-init user-data content"
  type        = string
}
