resource "oci_network_load_balancer_network_load_balancer" "sftp_lb" {

  compartment_id = var.lb_compartment_id
  subnet_id = data.oci_core_subnet.cn_sftp_lb_subnet.id
  display_name = var.lb_display_name

  is_preserve_source_destination = false
  is_private = false
}

resource "oci_network_load_balancer_backend_set" "sftp_servers_backend_set" {

  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.sftp_lb.id

  name   = "sftp-servers"
  policy = "FIVE_TUPLE"

  is_preserve_source = true
 
  health_checker {

    protocol = "TCP"

      port = 22

      interval_in_millis = var.lb_health_check_interval
      timeout_in_millis  = var.lb_health_check_timeout

      retries = var.lb_health_check_retries
    }
}

resource "oci_network_load_balancer_listener" "sftp_listener" {

  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.sftp_lb.id

  name = "sftp-listener"
  port = 22
  protocol = "TCP"

  default_backend_set_name = oci_network_load_balancer_backend_set.sftp_servers_backend_set.name 
}

resource "oci_network_load_balancer_backend" "stfp_server_backends" {

  count = length(oci_core_instance.cn_sftp_servers)

  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.sftp_lb.id
  backend_set_name         = oci_network_load_balancer_backend_set.sftp_servers_backend_set.name

  port = oci_network_load_balancer_listener.sftp_listener.port

  name       = format("sftp-server-%02d", count.index + 1)
  #ip_address = oci_core_instance.cn_sftp_servers[count.index].private_ip
  target_id = oci_core_instance.cn_sftp_servers[count.index].id
}