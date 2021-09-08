resource "oci_identity_customer_secret_key" "cn_sftp_customer_secret_key" {

  display_name = "cn-sftp-servers"
  user_id = var.user_ocid
}