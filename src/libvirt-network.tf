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

    # A records
    hosts  {
      hostname = format("api.%s", var.dns.domain)
      ip       = local.helper_node.ip
    }

    hosts  {
      hostname = format("api-int.%s", var.dns.domain)
      ip       = local.helper_node.ip
    }

    hosts  {
      hostname = format("etcd-0.%s", var.dns.domain)
      ip       = local.ocp_master.0.ip
    }

    hosts  {
      hostname = format("etcd-1.%s", var.dns.domain)
      ip       = local.ocp_master.1.ip
    }

    hosts  {
      hostname = format("etcd-2.%s", var.dns.domain)
      ip       = local.ocp_master.2.ip
    }

    # SRV records
    srvs {
      service  = "etcd-server-ssl"
      protocol = "tcp"
      target   = format("etcd-0.%s", var.dns.domain)
      port     = 2380
      priority = 0
      weight   = 100
    }

    srvs {
      service  = "etcd-server-ssl"
      protocol = "tcp"
      target   = format("etcd-1.%s", var.dns.domain)
      port     = 2380
      priority = 0
      weight   = 100
    }

    srvs {
      service  = "etcd-server-ssl"
      protocol = "tcp"
      target   = format("etcd-2.%s", var.dns.domain)
      port     = 2380
      priority = 0
      weight   = 100
    }
  }

  depends_on = [
    local_file.openshift_dnsmasq
  ]
}