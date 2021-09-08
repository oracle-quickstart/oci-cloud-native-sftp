locals {

  sftp_user_name = "foo"
  sftp_user_group = "sftp"
}

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

      sftp-user-group = local.sftp_user_group

      sftp-user-name = local.sftp_user_name
      sftp-user-public-key = var.servers_ssh_authorized_keys != "" ? var.servers_ssh_authorized_keys : tls_private_key.sftp_servers_key_pair[0].public_key_openssh

      host-key-rsa-private = indent(4, tls_private_key.sftp_servers_host_key_pair_rsa.private_key_pem)
      host-key-rsa-public = tls_private_key.sftp_servers_host_key_pair_rsa.public_key_openssh

      host-key-ecdsa-private = indent(4, tls_private_key.sftp_servers_host_key_pair_ecdsa.private_key_pem)
      host-key-ecdsa-public = tls_private_key.sftp_servers_host_key_pair_ecdsa.public_key_openssh

      sshd_config = base64encode(templatefile("${path.module}/cloud-init/resources/sshd_config", {
        sftp-user-group = local.sftp_user_group
      }))

      bootstrap-sh = base64encode(templatefile("${path.module}/cloud-init/resources/bootstrap.sh", {

        sftp-user-name = local.sftp_user_name
        sftp-user-group = local.sftp_user_group

        region = var.region
        bucket-namespace = "frv9ihqh1etj" #oci_objectstorage_namespace.objectstorage_namespace.namespace
        bucket-name = var.bucket_name
        s3-access-key = "9f8bf7decb7919e3d68c5003f02cd0de55d878a8" #oci_identity_customer_secret_key.cn_sftp_customer_secret_key.id 
        s3-secret-key = "TSiV9X5BXvZPbLJOyxamVfO75IEX+M9Spfk3o2za0rQ=" #oci_identity_customer_secret_key.cn_sftp_customer_secret_key.key
      }))
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