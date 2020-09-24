terraform {
  required_version = ">= 0.13.0"

  backend "local" {}

  required_providers {

    libivrt = {
      source  = "hashicorp/libvirt"
      version = "~> 0.6.2"
    }

    ct = {
      source  = "poseidon/ct"
      version = "~> 0.6.1"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 2.1"
    }

    template = {
      source  = "hashicorp/template"
      version = "~> 2.1"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 1.4"
    }

  }
}

provider "libvirt" {
  uri = "qemu:///system"
}
