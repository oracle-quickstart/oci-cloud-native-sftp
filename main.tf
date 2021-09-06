resource "tls_private_key" "sftp_servers_key_pair" {

  count = var.servers_ssh_authorized_keys != "" ? 0 : 1

  algorithm = "RSA"
  rsa_bits = 4096
}