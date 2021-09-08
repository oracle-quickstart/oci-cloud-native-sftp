terraform {

  # Required Terraform version 
  required_version = ">= 1.0.0"

  # Required OCI Terraform Provider version
  required_providers {
    oci = {
        source  = "hashicorp/oci"
        version = ">= 4.42.0"
    }
/*
    tls = {
      source = "invidian/tls"
      version = "2.2.1"
    }
    */
  }

  # Use OCI Object Storage as backend for storing Terraform state files
  #backend "http" {
  #    address = "https://objectstorage.eu-frankfurt-1.oraclecloud.com/<my-access-uri>" update_method = "PUT"
  #}
}

# Configure the Oracle Cloud Infrastructure provider with an API Key
provider "oci" {

  #tenancy_ocid = var.tenancy_ocid

  #user_ocid = var.user_ocid

  #fingerprint = var.fingerprint

  #private_key_path = var.private_key_path

  #region = var.region
}
