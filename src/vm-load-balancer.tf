locals {
  load_balancer = {
    hostname = "lb"
    fqdn     = format("lb.%s", var.dns.domain)
    ip       = lookup(var.ocp_inventory, "helper").ip
    mac      = lookup(var.ocp_inventory, "helper").mac
  }
}
