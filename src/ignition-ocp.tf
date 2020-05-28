data "template_file" "ocp_install_config" {
  template = file(format("%s/ignition/openshift/install-config.yaml.tpl", path.module))

  vars = {
    ocp_cluster_name = var.ocp_cluster.name
    ocp_dns_domain   = var.ocp_cluster.dns_domain
    ocp_nodes_cidr   = var.network.subnet
    ocp_pods_cidr    = var.ocp_cluster.pods_cidr
    ocp_pods_range   = var.ocp_cluster.pods_range
    ocp_svcs_cidr    = var.ocp_cluster.svcs_cidr
    ocp_pull_secret  = var.OCP_PULL_SECRET
    ocp_ssh_pubkey   = trimspace(tls_private_key.ssh_maintuser.public_key_openssh)
  }
}

resource "local_file" "ocp_install_config" {
  filename             = format("%s/ignition/openshift/%s/install-config.yaml",
    path.module, var.ocp_cluster.environment)
  content              = data.template_file.ocp_install_config.rendered
  file_permission      = "0644"
  directory_permission = "0755"

  provisioner "local-exec" {
    environment = {
      OCP_ENVIRONMENT = var.ocp_cluster.environment
    }
    command = "./generate-ocp-ignition.sh"
  }
}

# BUG: Will be allways recreated https://github.com/hashicorp/terraform/issues/11806 (milestone TF 0.13)
data "local_file" "ocp_ignition_bootstrap" {
  filename   = format("%s/ignition/openshift/%s/bootstrap.ign", path.module, var.ocp_cluster.environment)
  depends_on = [
    local_file.ocp_install_config
  ]
}

# BUG: Will be allways recreated https://github.com/hashicorp/terraform/issues/11806 (milestone TF 0.13)
data "local_file" "ocp_ignition_master" {
  filename   = format("%s/ignition/openshift/%s/master.ign", path.module, var.ocp_cluster.environment)
  depends_on = [
    local_file.ocp_install_config
  ]
}

# BUG: Will be allways recreated https://github.com/hashicorp/terraform/issues/11806 (milestone TF 0.13)
data "local_file" "ocp_ignition_worker" {
  filename   = format("%s/ignition/openshift/%s/worker.ign", path.module, var.ocp_cluster.environment)
  depends_on = [
    local_file.ocp_install_config
  ]
}