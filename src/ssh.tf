resource "tls_private_key" "ssh_maintuser" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "ssh_maintuser_public_key" {
  filename             = format("%s/ssh/maintuser/id_rsa.pub", path.module)
  content              = tls_private_key.ssh_maintuser.public_key_openssh
  file_permission      = "0600"
  directory_permission = "0700"
}

resource "local_file" "ssh_maintuser_private_key" {
  filename             = format("%s/ssh/maintuser/id_rsa", path.module)
  content              = tls_private_key.ssh_maintuser.private_key_pem
  file_permission      = "0400"
  directory_permission = "0700"
}