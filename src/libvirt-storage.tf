resource "libvirt_pool" "openshift" {
  name = var.libvirt.pool
  type = "dir"
  path = var.libvirt.pool_path
}