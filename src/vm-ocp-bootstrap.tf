locals {
  ocp_bootstrap = {
    hostname = "bootstrap"
    fqdn     = format("bootstrap.%s", var.dns.domain)
    ip       = lookup(var.ocp_inventory, "bootstrap").ip
    mac      = lookup(var.ocp_inventory, "bootstrap").mac
  }
}

module "ocp_bootstrap" {

  source = "./modules/ocp_node"

  id           = format("ocp-%s", local.ocp_bootstrap.hostname)
  fqdn         = local.ocp_bootstrap.fqdn
  ignition     = data.local_file.ocp_ignition_bootstrap.content
  cpu          = var.ocp_bootstrap.vcpu
  memory       = var.ocp_bootstrap.memory
  libvirt_pool = libvirt_pool.openshift.name
  os_image     = var.ocp_bootstrap.base_img
  disk_size    = var.ocp_bootstrap.size # Gigabytes
  network      = {
    name = libvirt_network.openshift.name
    ip   = local.ocp_bootstrap.ip
    mac  = local.ocp_bootstrap.mac
  }
}
