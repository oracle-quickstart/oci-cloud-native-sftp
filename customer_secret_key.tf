resource "oci_identity_customer_secret_key" "cn_sftp_customer_secret_key" {

  display_name = "cn-sftp-servers"
  user_id = var.current_user_ocid
}