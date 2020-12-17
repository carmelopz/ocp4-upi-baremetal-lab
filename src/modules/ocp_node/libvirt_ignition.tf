resource "libvirt_ignition" "ocp_node" {
  name    = format("%s.ign", var.id)
  pool    = var.libvirt_pool
  content = var.ignition

  lifecycle {
    ignore_changes = [
      content
    ]
  }
}
