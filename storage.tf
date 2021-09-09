
resource "oci_objectstorage_bucket" "cn_sftp_bucket" {

  compartment_id = var.s3_compatibility_compartment_id

  namespace = data.oci_objectstorage_namespace.bucket_namespace.namespace
  name      = var.bucket_name

  storage_tier = "Standard"
  access_type  = "NoPublicAccess"
  auto_tiering = "Disabled"
  versioning   = "Disabled"

  object_events_enabled =  true
}