resource "oci_network_load_balancer_network_load_balancer" "sftp_lb" {

  compartment_id = var.resources_compartment_id
  subnet_id = data.oci_core_subnet.cn_sftp_lb_subnet.id
  display_name = var.sftp_lb_display_name

  is_preserve_source_destination = true
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

      interval_in_millis = var.sftp_lb_health_check_interval
      timeout_in_millis  = var.sftp_lb_health_check_timeout

      retries = var.sftp_lb_health_check_retries
    }
}

resource "oci_network_load_balancer_listener" "sftp_listener" {

  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.sftp_lb.id

  name = "sftp-listener"
  port = 22
  protocol = "TCP"

  default_backend_set_name = oci_network_load_balancer_backend_set.sftp_servers_backend_set.name 
}