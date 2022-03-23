variable "region" {

  description = "Region of the Tenancy"
  type = string
}

variable "tenancy_ocid" {

  description = "OCID of the Tenancy"
  type = string
}

variable "current_user_ocid" {

  # Where to Get the Tenancy's OCID and User's OCID: https://docs.cloud.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#five
  description = "The user OCID"
  type = string
  default = ""
}

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

variable "servers_subnet_id" {

  description = "OCID of the subnet (private) where SFTP servers are instantiated"
  type = string
  default = ""
}

variable "servers_subnet_cidr" {

  description = "The CIDR of the subnet (private) to create for the SFTP servers"
  type = string
  default = "10.0.0.16/28"
}

variable "servers_subnet_dns_label" {

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

variable "lb_compartment_id" {

  description = "OCID of the compartment where creating the Network Load Balancer"
  type = string
}

variable "lb_display_name" {

  description = "The name of the Network Load Balancer"
  type = string
  default = "cn-sftp-lb"
}

variable "lb_health_check_interval" {

  description = "The interval, in milliseconds, used for checking SFTP servers health"
  type = number
  default = 10000
}

variable "lb_health_check_timeout" {

  description = "The timeout, in milliseconds, of SFTP servers health check"
  type = number
  default = 1000
}

variable "lb_health_check_retries" {

  description = "The number of retries made while checking for SFTP servers health"
  type = number
  default = 3
}

variable "servers_compartment_id" {

  description = "OCID of the compartment where creating the SFTP servers"
  type = string
}

variable "servers_display_name" {

  description = "The name of SFTP servers Compute instances"
  type = string
  default = "sftp-server"
}

variable "servers_hostname" {

  description = "The hostname patterns used for SFTP servers Compute instances"
  type = string
  default = "sftp-server"
}

variable "servers_shape" {

  description = "The shape used for SFTP servers Compute instances"
  type = string
  default = "VM.Standard.A1.Flex"
}

variable "servers_ocpus" {

  description = "The number of OCPUs used by a SFTP server Compute instance"
  type = number
  default = 1
}

variable "servers_memory" {

  description = "The memore assigned to a SFTP server Compute instance"
  type = number
  default = 32
}

variable "servers_image_id" {

  description = "The OCID of the image used for SFTP servers Compute instances"
  type = string
}

variable "servers_count" {

  description = "The number of SFTP servers to istantiate"
  type = number
  default = 2
}

variable "servers_ssh_authorized_keys" {

  description = "The public key, in OpenSSH format, allowed for connecting to SFTP servers Compute instances through SSH"
  type = string
  default = ""
}

variable "sftp_user_name" {

  description = "The name of the SFTP user"
  type = string
  default = "cloudnative"
}

variable "sftp_user_ssh_authorized_keys" {

  description = "The public key, in OpenSSH format, allowed for connecting to SFTP"
  type = string
}

variable "notifications_compartment_id" {

  description = "OCID of the compartment where creating OCI Notifications and Events resources"
  type = string
}

variable "notifications_email" {

  description = "The mail recipient of the messages about SFTP files changes"
  type = string
}