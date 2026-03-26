terraform {
  required_version = ">= 1.6.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.7.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "5.8.0"
    }
  }
}
