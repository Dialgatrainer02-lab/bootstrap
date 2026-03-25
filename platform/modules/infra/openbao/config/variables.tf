
variable "kv_mount_path" {
  type        = string
  description = "Path where KV v2 should be mounted."
  default     = "kv"
}

variable "external_ca_signer_command" {
  type        = string
  description = "Shell script body used to sign the generated intermediate CSR. CSR_FILE and SIGNED_CERT_FILE environment variables are provided."
  default     = null
}

variable "external_ca_csr_file_path" {
  type        = string
  description = "Local file path for the generated intermediate CSR. Relative paths are resolved from path.root."
  default     = "certs/external-ca.csr.pem"
}

variable "external_ca_signed_intermediate_file_path" {
  type        = string
  description = "Local file path where the signer writes the signed intermediate PEM. Relative paths are resolved from path.root."
  default     = "certs/external-ca.crt.pem"
}
