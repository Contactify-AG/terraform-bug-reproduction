variable "docker_registry" {
  default = "https://ghcr.io"
}

variable "docker_registry_user" {
  default = "Contactify-AG"
}

variable "docker_registry_password" {
  sensitive = true
}
