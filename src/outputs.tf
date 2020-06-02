# Helper node
output "ocp_helper_node" {
  value = {
    ip_address = local.helper_node.ip
    fqdn       = local.helper_node.fqdn
    ssh        = format("ssh -i src/ssh/maintuser/id_rsa maintuser@%s", local.helper_node.fqdn)
    metrics    = format("http://%s:5555/haproxy?stats", local.load_balancer.fqdn)
  }
}

# Registry mirroring
output "ocp_mirror" {
  value = format("oc adm release mirror --registry-config=%s --from=%s --to=%s --to-release-image=%s --insecure=true",
    local_file.ocp_pull_secret.filename,
    format("quay.io/openshift-release-dev/ocp-release:%s-x86_64", var.OCP_VERSION),
    format("%s:%s/ocp4", local.registry.fqdn, var.registry.port),
    format("%s:%s/ocp4:%s-x86_64", local.registry.fqdn, var.registry.port, var.OCP_VERSION)
  )
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
