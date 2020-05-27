resource "libvirt_network" "openshift" {
  name      = var.network.name
  domain    = var.dns.domain
  mode      = "nat"
  bridge    = "kubevirbr0"
  mtu       = 1500
  addresses = [ var.network.subnet ]
  autostart = true

  dhcp {
    enabled = true
  }

  dns {
    enabled    = true
    local_only = true

    # hosts  {
    #   hostname = format("api.%s", var.dns.internal_zone.domain)
    #   ip       = local.helper_node.ip
    # }
  }

  # xml {
  #   xslt = file(format("%s/xslt/network-zone.xml", path.module))
  # }

  depends_on = [
    local_file.openshift_dnsmasq
  ]
}