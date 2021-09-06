resource "oci_core_vcn" "cn_sftp_vcn" {

  count = (var.vcn_id != "" ? 0 : 1)

  compartment_id = var.network_compartment_id

  display_name = "cn-sftp-vcn"

  cidr_block = var.vcn_cidr
  dns_label  = var.vcn_dns_label
}

resource "oci_core_subnet" "cn_sftp_lb_subnet" {

  count = (var.lb_subnet_id != "" ? 0 : 1)

  compartment_id = var.network_compartment_id
  vcn_id         = data.oci_core_vcn.cn_sftp_vcn.id

  display_name = "cn-sftp-lb-subnet"

  cidr_block = var.lb_subnet_cidr
  dns_label  = var.lb_subnet_dns_label

  prohibit_internet_ingress  = false
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_subnet" "cn_sftp_servers_subnet" {

  count = (var.sftp_subnet_id != "" ? 0 : 1)

  compartment_id = var.network_compartment_id
  vcn_id         = data.oci_core_vcn.cn_sftp_vcn.id

  display_name = "cn-sftp-servers-subnet"

  cidr_block = var.sftp_subnet_cidr
  dns_label  = var.sftp_subnet_dns_label

  prohibit_internet_ingress  = false
  prohibit_public_ip_on_vnic = false
}