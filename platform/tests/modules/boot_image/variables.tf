variable "node_name" {
  type        = string
  description = "Proxmox node name to download the image onto."
}

variable "datastore_id" {
  type        = string
  description = "Datastore to store the downloaded image."
}

variable "content_type" {
  type        = string
  description = "Content type for the downloaded image (e.g., iso)."
  default     = "iso"
}

variable "url" {
  type        = string
  description = "URL to download."
}

variable "file_name" {
  type        = string
  description = "File name to save as in the datastore."
}

variable "overwrite" {
  type        = bool
  description = "If true, replace the downloaded image when the size has changed."
  default     = true
}

variable "overwrite_unmanaged" {
  type        = bool
  description = "If true, replace an existing unmanaged image with the same name."
  default     = false
}

