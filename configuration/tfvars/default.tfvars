helper_node = {
  base_img = "/var/lib/libvirt/images/fedora-coreos-31.20200310.3.0-qemu.x86_64.qcow2"
  vcpu     = 1
  memory   = 512
  size     = 20 # Gigabytes
}

load_balancer = {
  type    = "haproxy"
  version = "2.0.14"
}

registry = {
  version  = "2.7.1"
  username = "ocp"
  password = "changeme"
  port     = 5000
}

ocp_bootstrap = {
  base_img = "/var/lib/libvirt/images/rhcos-4.3.8-x86_64-qemu.x86_64.qcow2"
  vcpu     = 2
  memory   = 4096
}

ocp_master = {
  base_img = "/var/lib/libvirt/images/rhcos-4.3.8-x86_64-qemu.x86_64.qcow2"
  vcpu     = 3
  memory   = 8192
}