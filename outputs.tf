output "lb_ip_address" {
    value = oci_network_load_balancer_network_load_balancer.sftp_lb.ip_addresses[0].ip_address
}

output "sftp_servers_ip_addresses" {

    value = [for c in oci_core_instance.cn_sftp_servers: c.private_ip]
}

output "sftp_servers_host_keys" {

  value = {
    rsa = tls_private_key.sftp_servers_host_key_pair_rsa.public_key_openssh
    ecdsa = tls_private_key.sftp_servers_host_key_pair_ecdsa.public_key_openssh
  }
}