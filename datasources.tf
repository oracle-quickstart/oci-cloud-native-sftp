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

  subnet_id = var.sftp_subnet_id != "" ? var.sftp_subnet_id : oci_core_subnet.cn_sftp_servers_subnet[0].id
}

data "oci_objectstorage_namespace" "objectstorage_namespace" {
}