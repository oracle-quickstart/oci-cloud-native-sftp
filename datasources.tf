data "oci_identity_region_subscriptions" "regions" {

  tenancy_id = var.tenancy_ocid

  filter {
    name = "region_name"
    values = [var.region]
  }
}

data "oci_core_services" "services" {

  filter {
    name = "cidr_block"
    values = [format("all-%s-services-in-oracle-services-network", lower(data.oci_identity_region_subscriptions.regions.region_subscriptions[0].region_key))]
  }
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

data "oci_core_vcn" "cn_sftp_vcn" {
  vcn_id = var.vcn_id != "" ? var.vcn_id : oci_core_vcn.cn_sftp_vcn[0].id
}

data "oci_core_subnet" "cn_sftp_lb_subnet" {
  subnet_id = var.lb_subnet_id != "" ? var.lb_subnet_id : oci_core_subnet.cn_sftp_lb_subnet[0].id
}

data "oci_core_subnet" "cn_sftp_servers_subnet" {
  subnet_id = var.servers_subnet_id != "" ? var.servers_subnet_id : oci_core_subnet.cn_sftp_servers_subnet[0].id
}

data "oci_objectstorage_namespace" "bucket_namespace" {
}

data "oci_core_image" "cn_sftp_server_image" {
  image_id = var.servers_image_id
}