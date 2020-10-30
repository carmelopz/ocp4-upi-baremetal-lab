helper_node = {
  id       = "helper"
  base_img = "src/storage/images/fedora-coreos-32.20200629.3.0.x86_64.qcow2"
  vcpu     = 2
  memory   = 4096
  size     = 200 # Gigabytes
}

load_balancer = {
  type    = "haproxy"
  version = "2.0.14"
}

registry = {
  version    = "2.7.1"
  username   = "ocp"
  password   = "changeme"
  repository = "ocp4"
  port       = 5000
}

nfs = {
  version = "2.4.3"
}

ocp_bootstrap = {
  id       = "bootstrap"
  base_img = "src/storage/images/rhcos-4.4.3-x86_64-qemu.x86_64.qcow2"
  vcpu     = 2
  memory   = 4096
  size     = 60 # Gigabytes
}

ocp_master = {
  id       = "master"
  base_img = "src/storage/images/rhcos-4.4.3-x86_64-qemu.x86_64.qcow2"
  vcpu     = 4
  memory   = 16384
  size     = 120 # Gigabytes
}

ocp_worker = {
  id       = "worker"
  base_img = "src/storage/images/rhcos-4.4.3-x86_64-qemu.x86_64.qcow2"
  vcpu     = 4
  memory   = 8192
  size     = 200 # Gigabytes
}
