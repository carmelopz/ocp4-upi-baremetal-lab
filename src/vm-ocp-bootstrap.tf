locals {
  ocp_bootstrap = {
    hostname = "bootstrap"
    fqdn     = format("bootstrap.%s", var.dns.domain)
    ip       = lookup(var.ocp_inventory, "bootstrap").ip_address
    mac      = lookup(var.ocp_inventory, "bootstrap").mac_address
  }
}

resource "libvirt_ignition" "ocp_bootstrap" {
  name    = format("%s.ign", local.ocp_bootstrap.hostname)
  pool    = libvirt_pool.openshift.name
  content = data.local_file.ocp_ignition_bootstrap.content

  lifecycle {
    ignore_changes = [
      content
    ]
  }
}

resource "libvirt_volume" "ocp_bootstrap_image" {
  name   = format("%s-baseimg.qcow2", local.ocp_bootstrap.hostname)
  pool   = libvirt_pool.openshift.name
  source = var.ocp_bootstrap.base_img
  format = "qcow2"
}

resource "libvirt_volume" "ocp_bootstrap" {
  name           = format("%s-volume.qcow2", local.ocp_bootstrap.hostname)
  pool           = libvirt_pool.openshift.name
  base_volume_id = libvirt_volume.ocp_bootstrap_image.id
  format         = "qcow2"
  size           = var.ocp_bootstrap.size * pow(10, 9) # Bytes
}

resource "libvirt_domain" "ocp_bootstrap" {
  name    = format("ocp-%s", local.ocp_bootstrap.hostname)
  memory  = var.ocp_bootstrap.memory
  vcpu    = var.ocp_bootstrap.vcpu
  running = false

  coreos_ignition = libvirt_ignition.ocp_bootstrap.id

  disk {
    volume_id = libvirt_volume.ocp_bootstrap.id
    scsi      = false
  }

  network_interface {
    network_name   = libvirt_network.openshift.name
    hostname       = format("%s.%s", local.ocp_bootstrap.hostname, var.dns.domain)
    addresses      = [ local.ocp_bootstrap.ip ]
    mac            = local.ocp_bootstrap.mac
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
    command = format("ssh-keygen -R %s", self.network_interface.0.hostname)
  }
}
