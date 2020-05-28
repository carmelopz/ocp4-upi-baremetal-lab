resource "tls_private_key" "ocp_registry" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "ocp_registry" {
  private_key_pem = tls_private_key.ocp_registry.private_key_pem
  key_algorithm   = tls_private_key.ocp_registry.algorithm

  subject {
    common_name         = "Registry"
    organization        = "OCP"
    organizational_unit = "Baremetal Disconnected"
    country             = "ES"
    locality            = "Madrid"
    province            = "Madrid"
  }

  dns_names = [
    local.helper_node.fqdn,
    format("registry.%s", var.dns.domain)
  ]

  ip_addresses = [
    "127.0.0.1",
    local.helper_node.ip
  ]
}

resource "tls_locally_signed_cert" "ocp_registry" {
  cert_request_pem      = tls_cert_request.ocp_registry.cert_request_pem
  ca_cert_pem           = tls_self_signed_cert.ocp_root_ca.cert_pem
  ca_private_key_pem    = tls_private_key.ocp_root_ca.private_key_pem
  ca_key_algorithm      = tls_private_key.ocp_root_ca.algorithm
  validity_period_hours = 8760
  is_ca_certificate     = false
  set_subject_key_id    = true

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth"
  ]
}

resource "local_file" "ocp_registry_certificate_pem" {

  count = var.DEBUG ? 1 : 0

  filename             = format("%s/ca/clients/registry/certificate.pem", path.module)
  content              = tls_locally_signed_cert.ocp_registry.cert_pem
  file_permission      = "0600"
  directory_permission = "0700"
}

resource "local_file" "ocp_registry_private_key_pem" {

  count = var.DEBUG ? 1 : 0

  filename             = format("%s/ca/clients/registry/private.key", path.module)
  content              = tls_private_key.ocp_registry.private_key_pem
  file_permission      = "0600"
  directory_permission = "0700"
}
