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

    # Ingress controller routes
    dynamic "hosts" {
      for_each = [
        "console-openshift-console",
        "oauth-openshift",
        "grafana-openshift-monitoring",
        "prometheus-k8s-openshift-monitoring",
        "alertmanager-main-openshift-monitoring",
        "thanos-querier-openshift-monitoring",
        "downloads-openshift-console"
      ]
      content {
        hostname = format("%s.apps.%s", hosts.value, var.dns.domain)
        ip       = local.load_balancer.ip
      }
    }

  }

  # Wildcard for ingress controller routes
  xml {
    xslt = <<EOL
<?xml version="1.0" ?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dnsmasq="http://libvirt.org/schemas/network/dnsmasq/1.0">

     <!-- Identity template -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Override for target element -->
    <xsl:template match="network">
        <!-- Copy the element -->
        <xsl:copy>
            <!-- And everything inside it -->
            <xsl:apply-templates select="@* | node()"/>
            <!-- Additional dnsmasq options -->
            <dnsmasq:options>
                <dnsmasq:option value="address=/${format("apps.%s", var.dns.domain)}/${local.load_balancer.ip}"/>
            </dnsmasq:options>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
EOL
  }

  depends_on = [
    local_file.openshift_dnsmasq
  ]
}
