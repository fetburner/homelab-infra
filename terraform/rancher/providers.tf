terraform {
  required_version = ">= 1.12"

  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket = "homelab-terraform-state"
    key    = "rancher/terraform.tfstate"
    region = "auto"

    endpoints = {
      s3 = "https://abdb81a14388bfb3b2ccfe00525c16df.r2.cloudflarestorage.com"
    }

    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true
  }
}

provider "rancher2" {}
