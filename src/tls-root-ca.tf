resource "tls_private_key" "ocp_root_ca" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "ocp_root_ca" {
  private_key_pem       = tls_private_key.ocp_root_ca.private_key_pem
  key_algorithm         = tls_private_key.ocp_root_ca.algorithm
  validity_period_hours = 87600
  is_ca_certificate     = true
  set_subject_key_id    = true

  subject {
    common_name         = "OCP Root CA"
    organization        = "OCP"
    organizational_unit = "Baremetal Disconnected"
    country             = "ES"
    locality            = "Madrid"
    province            = "Madrid"
  }

  allowed_uses = [
    "cert_signing",
    "crl_signing"
  ]
}

resource "local_file" "ocp_root_ca_certificate_pem" {
  filename             = format("%s/ca/root-ca/certificate.pem", path.module)
  content              = tls_self_signed_cert.ocp_root_ca.cert_pem
  file_permission      = "0600"
  directory_permission = "0700"
}

resource "local_file" "ocp_root_ca_private_key_pem" {
  filename             = format("%s/ca/root-ca/certificate.key", path.module)
  content              = tls_private_key.ocp_root_ca.private_key_pem
  file_permission      = "0600"
  directory_permission = "0700"
}