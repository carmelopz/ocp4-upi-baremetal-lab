resource "libvirt_volume" "os_image" {
  name   = format("%s-%s", var.id, basename(var.os_image))
  pool   = var.libvirt_pool
  source = var.os_image
  format = "qcow2"
}

resource "libvirt_volume" "ocp_node" {
  name           = format("%s-volume.qcow2", var.id)
  pool           = var.libvirt_pool
  base_volume_id = libvirt_volume.os_image.id
  size           = var.disk_size * 1073741824 # Bytes
  format         = "qcow2"
}
