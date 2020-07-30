resource "libvirt_network" "openshift" {
  name      = var.network.name
  domain    = var.dns.domain
  mode      = "route"
  bridge    = "virbr-ocp"
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
    hosts {
      hostname = local.registry.fqdn
      ip       = local.registry.ip
    }

    hosts {
      hostname = local.load_balancer.fqdn
      ip       = local.load_balancer.ip
    }

    hosts {
      hostname = format("api.%s", var.dns.domain)
      ip       = local.load_balancer.ip
    }

    hosts {
      hostname = format("api-int.%s", var.dns.domain)
      ip       = local.load_balancer.ip
    }

    hosts {
      hostname = format("etcd-0.%s", var.dns.domain)
      ip       = local.ocp_master.0.ip
    }

    hosts {
      hostname = format("etcd-1.%s", var.dns.domain)
      ip       = local.ocp_master.1.ip
    }

    hosts {
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

    # Ingress controller routes
    hosts {
      hostname = format("console-openshift-console.apps.%s", var.dns.domain)
      ip       = local.load_balancer.ip
    }

    hosts {
      hostname = format("oauth-openshift.apps.%s", var.dns.domain)
      ip       = local.load_balancer.ip
    }

    hosts {
      hostname = format("grafana-openshift-monitoring.apps.%s", var.dns.domain)
      ip       = local.load_balancer.ip
    }

    hosts {
      hostname = format("prometheus-k8s-openshift-monitoring.apps.%s", var.dns.domain)
      ip       = local.load_balancer.ip
    }

    hosts {
      hostname = format("alertmanager-main-openshift-monitoring.apps.%s", var.dns.domain)
      ip       = local.load_balancer.ip
    }

    hosts {
      hostname = format("thanos-querier-openshift-monitoring.apps.%s", var.dns.domain)
      ip       = local.load_balancer.ip
    }

    hosts {
      hostname = format("downloads-openshift-console.apps.%s", var.dns.domain)
      ip       = local.load_balancer.ip
    }

  }

  xml {
    xslt = data.template_file.openshift_libvirt_dns.rendered
  }

  depends_on = [
    local_file.openshift_dnsmasq
  ]
}
