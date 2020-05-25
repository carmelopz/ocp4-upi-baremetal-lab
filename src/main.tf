terraform {
  backend "local" {}
}

provider "libvirt" {
    uri = "qemu:///system"
}