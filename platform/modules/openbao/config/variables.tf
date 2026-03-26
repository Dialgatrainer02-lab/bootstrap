
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

variable "external_ca_root_certificate_file_path" {
  type        = string
  description = "Local file path of the external root CA certificate PEM used as trust anchor. Relative paths are resolved from path.root."
  default     = "Example_Labs_Root_CA_v1.crt"
}

variable "pki_api_base_url" {
  type        = string
  description = "Base OpenBao API URL used for PKI AIA/CRL/OCSP URLs (for example http://192.168.0.51:8200)."
  default     = "http://127.0.0.1:8200"
}

variable "pki_cluster_base_url" {
  type        = string
  description = "Base OpenBao cluster API URL used for PKI cluster path config. Defaults to pki_api_base_url when null."
  default     = null
}

variable "pki_wait_base_url" {
  type        = string
  description = "Base OpenBao API URL used only for readiness waiting (for example http://192.168.0.51:8200). Defaults to pki_api_base_url when null."
  default     = null
}

variable "pki_role_allowed_domains" {
  type        = list(string)
  description = "Allowed DNS domains for the issuing role in the pki_iss mount."
  default     = ["example.com"]
}
