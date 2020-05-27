# Helper node
output "ocp_helper_node" {
  value = {
    ip_address = libvirt_domain.helper_node.network_interface.0.addresses.0
    fqdn       = libvirt_domain.helper_node.network_interface.0.hostname
    ssh        = format("ssh -i src/ssh/maintuser/id_rsa maintuser@%s",
      libvirt_domain.helper_node.network_interface.0.hostname)
  }
}

# OCP Bootstrap
output "ocp_bootstrap_node" {
  value = {
    ip_address = libvirt_domain.ocp_bootstrap.network_interface.0.addresses.0
    fqdn       = libvirt_domain.ocp_bootstrap.network_interface.0.hostname
    ssh        = format("ssh -i src/ssh/maintuser/id_rsa core@%s",
      libvirt_domain.ocp_bootstrap.network_interface.0.hostname)
  }
}