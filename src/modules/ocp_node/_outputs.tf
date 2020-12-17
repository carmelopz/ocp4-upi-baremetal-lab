output "libvirt_domain_uuid" {
  description = "Libvirt domain UUID"
  value       = libvirt_domain.ocp_node.id
}
