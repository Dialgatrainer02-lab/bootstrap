variable "service_dns_domain" {
  type        = string
  description = "DNS domain used for service hostnames (for example lab.local)."
  default     = "lab.local"
}
variable "local_mirror_repos_archive_path" {
  type        = string
  description = "Local filesystem path to the prebuilt local mirror archive produced by artifacts/mirror/reposync.sh."
  default     = null
}
