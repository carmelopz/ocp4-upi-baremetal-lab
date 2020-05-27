# Helper node
output "ocp_helper_node" {
  value = {
    ip_address = local.helper_node.ip
    fqdn       = local.helper_node.fqdn
    ssh        = format("ssh -i src/ssh/maintuser/id_rsa maintuser@%s", local.helper_node.fqdn)
    metrics    = format("http://%s:5555/haproxy?stats", local.helper_node.fqdn)
  }
}

# OCP Bootstrap
output "ocp_bootstrap_node" {
  value = {
    ip_address = local.ocp_bootstrap.ip
    fqdn       = local.ocp_bootstrap.fqdn
    ssh        = format("ssh -i src/ssh/maintuser/id_rsa core@%s", local.ocp_bootstrap.fqdn)
  }
}

# OCP masters
output "ocp_masters" {
  value = {
    ip_address = local.ocp_master.*.ip
    fqdn       = local.ocp_master.*.fqdn
    ssh        = formatlist("ssh -i src/ssh/maintuser/id_rsa core@%s", local.ocp_master.*.fqdn)
  }
}
