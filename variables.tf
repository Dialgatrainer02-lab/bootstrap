variable "pve_endpoint" {
  type = string
  description = "proxmox virtual environement endpoint with protocol and port"
}

variable "pve_username" {
  type = string
  description = "pve username with domain eg root@pam"
}

variable "pve_password" {
  type = string
  description = "password for the provided user"
}