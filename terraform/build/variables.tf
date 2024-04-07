variable "gcp_project_name" {
  type = string
}

variable "gcp_region" {
  type    = string
  default = "europe-west2-a"
}

variable "ipsec-psk" {
  type = string
}

variable "ipsec-username" {
  type = string
}

variable "ipsec-password" {
  type = string
}

variable "vm_name" {
  type = string
}
