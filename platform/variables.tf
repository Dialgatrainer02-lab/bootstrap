variable "cluster_name" {
  type        = string
  description = "Logical name for this platform/cluster."
}

variable "service_dns_domain" {
  type        = string
  description = "DNS domain used for service hostnames (for example lab.local)."
  default     = "lab.local"
}
