libvirt = {
  pool      = "openshift"
  pool_path = "/var/lib/libvirt/storage/openshift"
}

network = {
  name    = "openshift"
  subnet  = "10.0.0.0/24"
  gateway = "10.0.0.1"
}

dns = {
  domain = "ocp.bmlab.int"
  server = "10.0.0.1"
}

ocp_inventory = {
  "lb" = {
    ip_address  = "10.0.0.250"
    mac_address = "0A:00:00:00:00:00"
  }
  "bootstrap" = {
    ip_address  = "10.0.0.10"
    mac_address = "AA:00:00:00:00:00"
  }
  "master00" = {
    ip_address  = "10.0.0.11"
    mac_address = "AA:00:00:00:00:01"
  }
  "master01" = {
    ip_address  = "10.0.0.12"
    mac_address = "AA:00:00:00:00:02"
  }
  "master02" = {
    ip_address  = "10.0.0.13"
    mac_address = "AA:00:00:00:00:03"
  }
}