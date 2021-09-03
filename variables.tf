/*

variable "compartment_id" {

  description = "OCID of the compartment where creating resources"
  type = string
}
*/

variable "network_compartment_id" {

  description = "OCID of the compartment where creating network resources"
  type = string
  default = ""
}

variable "vcn_id" {

  description = "OCID of the VCN to use for configuring a Cloud Native SFTP"
  type = string
  default = ""
}

variable "vcn_cidr" {

  description = "The CIDR of the VCN to create for configuring a Cloud Native SFTP"
  type = string
  default = "10.0.0.0/26"
}

variable "vcn_dns_label" {

  description = "The DNS label of the Cloud Native SFTP VCN"
  type = string
  default = "sftp"
}

variable "lb_subnet_id" {

  description = "OCID of the subnet (public) where the Network Load Balancer is instantiated"
  type = string
  default = ""
}

variable "lb_subnet_cidr" {

  description = "The CIDR of the subnet (public) to create for the Network Load Balancer"
  type = string
  default = "10.0.0.0/28"
}

variable "lb_subnet_dns_label" {

  description = "The DNS label of Network Load Balancer subnet"
  type = string
  default = "lb"
}

variable "sftp_subnet_id" {

  description = "OCID of the subnet (private) where SFTP servers are instantiated"
  type = string
  default = ""
}

variable "sftp_subnet_cidr" {

  description = "The CIDR of the subnet (private) to create for the SFTP servers"
  type = string
  default = "10.0.0.16/28"
}

variable "sftp_subnet_dns_label" {

  description = "The DNS label of SFTP servers subnet"
  type = string
  default = "servers"
}

variable "s3_compatibility_compartment_id" {
  
  description = "OCID of the compartment designated for S3 Compatibility API"
  type = string
}

variable "bucket_name" {

  description = "The name of the bucket, in designated S3 Compatibility compartment, where to store files"
  type = string
  default = "cn-sftp-bucket"
}

variable "resources_compartment_id" {

  description = "OCID of the compartment where creting SFTP resources"
  type = string
}

variable "sftp_lb_display_name" {

  description = "The name of the Network Load Balancer"
  type = string
  default = "cn-sftp-lb"
}

variable "sftp_lb_health_check_interval" {

  description = "The Network Load Balancer health check interval, in milliseconds"
  type = number
  default = 10000
}

variable "sftp_lb_health_check_timeout" {

  description = "The Network Load Balancer health check timeout, in milliseconds"
  type = number
  default = 5000
}

variable "sftp_lb_health_check_retries" {

  description = "The number of retries made by the Network Load Balancer while performing backends health check"
  type = number
  default = 3
}