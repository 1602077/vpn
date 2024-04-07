terraform {
  required_version = ">= 1.7.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.23.0"
    }
  }

}

provider "google" {
  project = var.gcp_project_name
  region  = var.gcp_region
}

data "google_client_config" "provider" {}

module "compute" {
  source         = "../modules/compute"
  vm_name        = var.vm_name
  ipsec-password = var.ipsec-password
  ipsec-username = var.ipsec-username
  ipsec-psk      = var.ipsec-psk
}

module "network" {
  source = "../modules/network"
}
