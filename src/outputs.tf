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
output "ocp_registry" {
  value = {
    mirror_images = format("./upload-mirror-images.sh %s %s %s",
      format("%s:%s/%s", local.registry.fqdn, var.registry.port, var.registry.repository),
      format("%s-x86_64", var.OCP_VERSION),
      local_file.ocp_pull_secret.filename
    )
    mirror_catalog = format("./upload-operator-catalog.sh %s %s %s",
      format("%s:%s/%s", local.registry.fqdn, var.registry.port, var.registry.repository),
      format("%s", var.OCP_VERSION),
      local_file.ocp_pull_secret.filename
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
