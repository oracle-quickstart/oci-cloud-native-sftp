resource "oci_core_instance" "cn_sftp_servers" {

  count = var.servers_count

  compartment_id = var.servers_compartment_id

  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[count.index % (length(data.oci_identity_availability_domains.ads.availability_domains) - 1)].name

  display_name = format("%s-%02d", var.servers_display_name, count.index + 1)

  shape = var.servers_shape

  shape_config {
    
    ocpus = var.servers_ocpus
    memory_in_gbs = var.servers_ocpus * 64
  }

  source_details {

    source_type = "image"
    source_id   = var.servers_image_id
  }

  create_vnic_details {

    subnet_id = data.oci_core_subnet.cn_sftp_servers_subnet.id

    display_name   = format("vnic-%s-%02d", var.servers_hostname, count.index + 1)
    hostname_label = format("%s-%02d", var.servers_hostname, count.index + 1)

    assign_public_ip = true
  }

  metadata = {

   ssh_authorized_keys = var.servers_ssh_authorized_keys != "" ? var.servers_ssh_authorized_keys : tls_private_key.sftp_servers_key_pair[0].public_key_openssh
   user_data = base64encode(templatefile("${path.module}/cloud-init/cloud-init.yaml", {

    rsa-private = indent(4, tls_private_key.sftp_servers_host_key_pair_rsa.private_key_openssh)
    rsa-public = tls_private_key.sftp_servers_host_key_pair_rsa.public_key_openssh

    ecdsa-private = indent(4, tls_private_key.sftp_servers_host_key_pair_ecdsa.private_key_openssh)
    ecdsa-public = tls_private_key.sftp_servers_host_key_pair_ecdsa.public_key_openssh
    #oci-hostname-conf = filebase64("${path.module}/cloud-init/oci-hostname.conf")

    /*
    drupal-env = base64encode(templatefile("${path.module}/cloud-init/drupal-env.sh", {
      database-host = var.drupal.instance_configuration.properties.database_host
      database-port = var.drupal.instance_configuration.properties.database_port
      database-name = var.drupal.instance_configuration.properties.database_name
      database-username = var.drupal.instance_configuration.properties.database_username
      database-password-secret-id = var.drupal.instance_configuration.properties.database_password_secret_id
      drupal-saml-environment = var.drupal.instance_configuration.properties.drupal_saml_environment
      drupal-error-level = var.drupal.instance_configuration.properties.drupal_error_level
      s3-access-key-secret-id = var.drupal.instance_configuration.properties.s3_access_key_secret_id
      s3-secret-key-secret-id = var.drupal.instance_configuration.properties.s3_secret_key_secret_id
      redis-seeds = var.drupal.instance_configuration.properties.redis_seeds
      redis-nodes = var.drupal.instance_configuration.properties.redis_nodes
      redis-password-secret-id = var.drupal.instance_configuration.properties.redis_password_secret_id
    }))
    
    php-ini-update = filebase64("${path.module}/cloud-init/php-ini-update.sh")
    drupal-saml-update = filebase64("${path.module}/cloud-init/drupal-saml-update.sh")
    drupal-settings-update = filebase64("${path.module}/cloud-init/drupal-settings-update.sh")
    */
    }))
  }

  agent_config {

    are_all_plugins_disabled = false

    is_management_disabled = false
    is_monitoring_disabled = false

    plugins_config {

      name          = "Bastion"
      desired_state = "ENABLED"
    }
  }
}