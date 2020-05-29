locals {
  registry_tls = {
    certificate = format("%s%s", tls_locally_signed_cert.ocp_registry.cert_pem,
      tls_self_signed_cert.ocp_root_ca.cert_pem)
    private_key = tls_private_key.ocp_registry.private_key_pem
  }
}

data "template_file" "helper_node_ignition" {
  template = file(format("%s/ignition/helper-node/ignition.yml.tpl", path.module))

  vars = {
    fqdn       = local.helper_node.fqdn
    ssh_pubkey = trimspace(tls_private_key.ssh_maintuser.public_key_openssh)

    haproxy_version = var.helper_node.haproxy_version
    haproxy_dns     = var.network.gateway

    registry_version         = var.helper_node.registry_version
    registry_htpasswd        = format("%s:%s", "ocp", bcrypt("changeme"))
    registry_tls_certificate = indent(10, local.registry_tls.certificate)
    registry_tls_private_key = indent(10, local.registry_tls.private_key)

    ocp_bootstrap_fqdn = local.ocp_bootstrap.fqdn
    ocp_master_0_fqdn  = local.ocp_master.0.fqdn
    ocp_master_1_fqdn  = local.ocp_master.1.fqdn
    ocp_master_2_fqdn  = local.ocp_master.2.fqdn
  }
}

resource "local_file" "helper_node_ignition" {
  filename             = format("%s/ignition/helper-node/ignition.yml", path.module)
  content              = data.template_file.helper_node_ignition.rendered
  file_permission      = "0644"
  directory_permission = "0755"

  provisioner "local-exec" {
    command = format("fcct --pretty --strict < %s > %s",
        format("%s/ignition/helper-node/ignition.yml", path.module),
        format("%s/ignition/helper-node/ignition.json", path.module))
  }
}

# BUG: Will be allways recreated https://github.com/hashicorp/terraform/issues/11806 (milestone TF 0.13)
data "local_file" "helper_node_ignition" {
  filename   = format("%s/ignition/helper-node/ignition.json", path.module)
  depends_on = [
    local_file.helper_node_ignition
  ]
}
