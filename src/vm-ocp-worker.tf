locals {
  ocp_worker = [
    for index in range(var.ocp_cluster.num_workers) :
      {
        hostname = format("worker%02d", index)
        fqdn     = format("worker%02d.%s", index, var.dns.domain)
        ip       = lookup(var.ocp_inventory, format("worker%02d", index)).ip
        mac      = lookup(var.ocp_inventory, format("worker%02d", index)).mac
      }
  ]
}

resource "libvirt_ignition" "ocp_worker" {

  count = var.ocp_cluster.num_workers

  name    = format("%s.ign", element(local.ocp_worker, count.index).hostname)
  pool    = libvirt_pool.openshift.name
  content = data.local_file.ocp_ignition_worker.content

  lifecycle {
    ignore_changes = [
      content
    ]
  }
}

resource "libvirt_volume" "ocp_worker_image" {
  name   = format("%s-baseimg.qcow2", element(local.ocp_worker, 0).hostname)
  pool   = libvirt_pool.openshift.name
  source = var.ocp_worker.base_img
  format = "qcow2"
}

resource "libvirt_volume" "ocp_worker" {

  count = var.ocp_cluster.num_workers

  name           = format("%s-volume.qcow2", element(local.ocp_worker, count.index).hostname)
  pool           = libvirt_pool.openshift.name
  base_volume_id = libvirt_volume.ocp_worker_image.id
  size           = var.ocp_worker.size * pow(10, 9) # Bytes
  format         = "qcow2"
}

resource "libvirt_domain" "ocp_worker" {

  count = var.ocp_cluster.num_workers

  name    = format("ocp-%s", element(local.ocp_worker, count.index).hostname)
  memory  = var.ocp_worker.memory
  vcpu    = var.ocp_worker.vcpu
  running = false

  coreos_ignition = element(libvirt_ignition.ocp_worker.*.id, count.index)

  disk {
    volume_id = element(libvirt_volume.ocp_worker.*.id, count.index)
    scsi      = false
  }

  network_interface {
    network_name   = libvirt_network.openshift.name
    hostname       = element(local.ocp_worker, count.index).fqdn
    addresses      = [ element(local.ocp_worker, count.index).ip ]
    mac            = element(local.ocp_worker, count.index).mac
    wait_for_lease = true
  }

  console {
    type           = "pty"
    target_type    = "serial"
    target_port    = "0"
    source_host    = "127.0.0.1"
    source_service = "0"
  }

  graphics {
    type           = "spice"
    listen_type    = "address"
    listen_address = "127.0.0.1"
    autoport       = true
  }

  lifecycle {
    ignore_changes = [
      running,
      network_interface.0.addresses
    ]
  }

  provisioner "local-exec" {
    when    = destroy
    command = format("ssh-keygen -R %s || true", self.network_interface.0.hostname)
  }
}
