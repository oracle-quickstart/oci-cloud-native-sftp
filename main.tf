resource "tls_private_key" "sftp_servers_host_key_pair_rsa" {

  algorithm = "RSA"
  rsa_bits = 4096
}

resource "tls_private_key" "sftp_servers_host_key_pair_ecdsa" {

  algorithm = "ECDSA"
  ecdsa_curve = "P256"
}

#HostKey /etc/ssh/ssh_host_ed25519_key
resource "tls_private_key" "sftp_servers_key_pair" {

  count = var.servers_ssh_authorized_keys != "" ? 0 : 1

  algorithm = "RSA"
  rsa_bits = 4096
}