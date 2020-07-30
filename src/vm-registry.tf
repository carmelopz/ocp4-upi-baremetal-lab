locals {
  registry = {
    hostname = "registry"
    fqdn     = format("registry.%s", var.dns.domain)
    ip       = lookup(var.ocp_inventory, "helper").ip
    mac      = lookup(var.ocp_inventory, "helper").mac
  }
}
