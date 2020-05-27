# Node helper
output "ocp_node_helper" {
  value = {
    ip_address = libvirt_domain.helper_node.network_interface.0.addresses.0
    fqdn       = libvirt_domain.helper_node.network_interface.0.hostname
    ssh        = format("ssh -i src/ssh/maintuser/id_rsa maintuser@%s",
      libvirt_domain.helper_node.network_interface.0.hostname)
  }
}