terraform {
  backend "local" {}
}

provider "local" {
  version = "~> 1.4"
}

provider "template" {
  version = "~> 2.1"
}

provider "tls" {
  version = "~> 2.1"
}

provider "libvirt" {
  uri = "qemu:///system"
}