variable "issuer" {
  description = "Intermediate issuer settings."
  type = object({
    backend          = string
    key_type         = string
    key_bits         = number
    name             = string
    organization     = string
    certificate_name = string
  })
}

variable "signer_command" {
  type        = string
  description = "Local command used to sign the CSR. Terraform sets CSR_FILE and SIGNED_CERT_FILE env vars for this command."
}

variable "csr_file_path" {
  type        = string
  description = "Local file path where the CSR is written. Relative paths are resolved from path.root."
  default     = "certs/external-ca.csr.pem"
}

variable "signed_intermediate_file_path" {
  type        = string
  description = "Local file path for the signed intermediate PEM produced by signer_command. Relative paths are resolved from path.root."
  default     = "certs/external-ca.crt.pem"
}
