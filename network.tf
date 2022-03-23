locals {

  is_service_gw_enough = data.oci_core_image.cn_sftp_server_image.operating_system == "Oracle Linux"
}

resource "oci_core_vcn" "cn_sftp_vcn" {

  count = (var.vcn_id != "" ? 0 : 1)

  compartment_id = var.network_compartment_id

  display_name = "cn-sftp-vcn"

  cidr_block = var.vcn_cidr
  dns_label  = var.vcn_dns_label
}

resource "oci_core_internet_gateway" "cn_sftp_internet_gw" {

  count = (var.vcn_id != "" ? 0 : 1)

  compartment_id = var.network_compartment_id 
  vcn_id         = data.oci_core_vcn.cn_sftp_vcn.id

  display_name = "cn-sftp-internet-gateway"
}

resource "oci_core_nat_gateway" "cn_sftp_nat_gw" {

  count = (var.vcn_id == "" && !local.is_service_gw_enough ? 1 : 0)

  compartment_id = var.network_compartment_id 
  vcn_id         = data.oci_core_vcn.cn_sftp_vcn.id

  display_name = "cn-sftp-nat-gateway"

  block_traffic = false
}

resource "oci_core_service_gateway" "cn_sftp_service_gw" {

  count = (var.vcn_id == "" && local.is_service_gw_enough ? 1 : 0)

  compartment_id = var.network_compartment_id 
  vcn_id         = data.oci_core_vcn.cn_sftp_vcn.id

  display_name = "cn-sftp-service-gateway"

  services {
    service_id = data.oci_core_services.services.services[0].id
  }
}

resource "oci_core_route_table" "cn_sftp_lb_subnet_rt" {

  count = (var.lb_subnet_id != "" ? 0 : 1)

  compartment_id = var.network_compartment_id
  vcn_id         = data.oci_core_vcn.cn_sftp_vcn.id

  display_name = "cn-sftp-lb-subnet-route-table"

  route_rules {

    network_entity_id = oci_core_internet_gateway.cn_sftp_internet_gw[0].id

    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }
}

resource "oci_core_route_table" "cn_sftp_servers_subnet_rt" {

  count = (var.lb_subnet_id != "" ? 0 : 1)

  compartment_id = var.network_compartment_id
  vcn_id         = data.oci_core_vcn.cn_sftp_vcn.id

  display_name = "cn-sftp-servers-subnet-route-table"

  route_rules {

    network_entity_id = local.is_service_gw_enough ? oci_core_service_gateway.cn_sftp_service_gw[0].id : oci_core_nat_gateway.cn_sftp_nat_gw[0].id

    destination      = local.is_service_gw_enough ? data.oci_core_services.services.services[0].cidr_block : "0.0.0.0/0"
    destination_type = local.is_service_gw_enough ? "SERVICE_CIDR_BLOCK" : "CIDR_BLOCK"
  }
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

resource "oci_core_route_table_attachment" "cn_sftp_lb_subnet_rt_attachment" {

  count = (var.lb_subnet_id != "" ? 0 : 1)

  route_table_id = oci_core_route_table.cn_sftp_lb_subnet_rt[0].id
  subnet_id      = data.oci_core_subnet.cn_sftp_lb_subnet.id  
}

resource "oci_core_subnet" "cn_sftp_servers_subnet" {

  count = (var.servers_subnet_id != "" ? 0 : 1)

  compartment_id = var.network_compartment_id
  vcn_id         = data.oci_core_vcn.cn_sftp_vcn.id

  display_name = "cn-sftp-servers-subnet"

  cidr_block = var.servers_subnet_cidr
  dns_label  = var.servers_subnet_dns_label

  prohibit_internet_ingress  = true
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_route_table_attachment" "cn_sftp_servers_subnet_rt_attachment" {

  count = (var.servers_subnet_id != "" ? 0 : 1)

  route_table_id = oci_core_route_table.cn_sftp_servers_subnet_rt[0].id
  subnet_id      = data.oci_core_subnet.cn_sftp_servers_subnet.id  
}