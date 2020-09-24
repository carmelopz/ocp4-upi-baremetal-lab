# Helper node
output "ocp_helper_node" {
  value = {
    fqdn    = local.helper_node.fqdn
    ip      = local.helper_node.ip
    ssh     = format("ssh -i %s maintuser@%s", local_file.ssh_maintuser_private_key.filename, local.helper_node.fqdn)
    metrics = format("http://%s:5555/haproxy?stats", local.load_balancer.fqdn)
  }
}

# OCP Bootstrap
output "ocp_bootstrap_node" {
  value = {
    fqdn = local.ocp_bootstrap.fqdn
    ip   = local.ocp_bootstrap.ip
    ssh  = format("ssh -i %s core@%s", local_file.ssh_maintuser_private_key.filename, local.ocp_bootstrap.fqdn)
  }
}

# OCP masters
output "ocp_masters" {
  value = {
    fqdn = local.ocp_master.*.fqdn
    ip   = local.ocp_master.*.ip
    ssh  = formatlist("ssh -i %s core@%s", local_file.ssh_maintuser_private_key.filename, local.ocp_master.*.fqdn)
  }
}

# OCP workers
output "ocp_workers" {
  value = {
    fqdn = local.ocp_worker.*.fqdn
    ip   = local.ocp_worker.*.ip
    ssh  = formatlist("ssh -i %s core@%s", local_file.ssh_maintuser_private_key.filename, local.ocp_worker.*.fqdn)
  }
}
