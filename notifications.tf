resource "oci_ons_notification_topic" "cn_sftp_bucket_events_topic" {

  compartment_id = var.notifications_compartment_id

  name        = "cn-sftp-updates"
  description = "Topic about actions performed on files handled through Cloud Native SFTP"
}

resource "oci_ons_subscription" "cn_sftp_events_subscription" {

  compartment_id = var.notifications_compartment_id

  topic_id = oci_ons_notification_topic.cn_sftp_bucket_events_topic.id
  protocol = "EMAIL"
  endpoint = var.notifications_email
}

resource "oci_events_rule" "cn_sftp_bucket_events" {

  compartment_id = var.notifications_compartment_id

  display_name = "cn-sftp-bucket-changes"

  condition  = format("{\"eventType\":[\"com.oraclecloud.objectstorage.createobject\",\"com.oraclecloud.objectstorage.updateobject\",\"com.oraclecloud.objectstorage.deleteobject\"],\"data\":{\"additionalDetails\":{\"bucketName\":[\"%s\"]}}}", var.bucket_name)
  is_enabled = true

  actions {

    actions {

      action_type = "ONS"
      topic_id    = oci_ons_notification_topic.cn_sftp_bucket_events_topic.id
      is_enabled  = true
    }
  }
}