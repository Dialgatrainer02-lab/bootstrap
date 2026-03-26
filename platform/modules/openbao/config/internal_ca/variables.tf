variable "issuer" {
  description = "Issuing CA settings."
  type = object({
    backend          = string
    parent_backend   = string
    parent_issuer    = string
    key_type         = string
    key_bits         = number
    name             = optional(string, "default")
    organization     = string
    certificate_name = string
    ttl              = optional(string, "8760h")
  })
}

variable "role" {
  description = "Leaf certificate issuing role settings."
  type = object({
    name                        = optional(string, "example_com")
    max_ttl_seconds             = optional(number, 3600)
    allowed_domains             = optional(list(string), ["example.com"])
    allow_subdomains            = optional(bool, true)
    allow_ip_sans               = optional(bool, true)
    allow_wildcard_certificates = optional(bool, false)
    no_store                    = optional(bool, true)
  })
  default = {}
}
