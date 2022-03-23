# cloud-native-sftp
Have you ever wondered how to turn a legacy, but still widely adopted, solution like SFTP into a fresh Cloud Native solution ?

That's a Terraform module for [_Turning SFTP Cloud Native_](https://blogs.oracle.com/cloud-infrastructure/post/turning-sftp-cloud-native), therefore you may would like to know more and go through [_Turning SFTP Cloud Native...with a click_](https://blogs.oracle.com/cloud-infrastructure/post/turning-sftp-cloud-native-with-a-click) post on [Oracle Blogs](https://blogs.oracle.com/).

## Prerequisites
- Permission to `manage` the following types of resources in your Oracle Cloud Infrastructure tenancy:
  - `vcns`
  - `internet-gateways`
  - `service-gateways`
  - `nat-gateways`
  - `route-tables`
  - `security-lists`
  - `subnets`
  - `load-balancers`
  - `instances`
  - `buckets`
  - `objects`
  - `instances`
  - `cloudevents-rules`
  - `ons-topics`
  - `ons-subscriptions`
- Quota to create the following resources:
  - VCN: 1
  - Subnet: 2
  - Internet Gateway: 1
  - Service Gateway/NAT Gateway: 1
  - Routing Table rules: 2
  - Network Load Balancer: 1
  - Object Storage Bucket: 1
  - Compute instances: 2

If you don't have the required permissions and quota, contact your tenancy administrator. See [Policy Reference](https://docs.cloud.oracle.com/en-us/iaas/Content/Identity/Reference/policyreference.htm), [Service Limits](https://docs.cloud.oracle.com/en-us/iaas/Content/General/Concepts/servicelimits.htm), [Compartment Quotas](https://docs.cloud.oracle.com/iaas/Content/General/Concepts/resourcequotas.htm).

## Deploy Using Oracle Resource Manager
1. Click [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?region=home&zipUrl=https://github.com/oracle-quickstart/oci-cloud-native-sftp/releases/latest/download/oci-cloud-native-sftp-stack-latest.zip)

    If you aren't already signed in, when prompted, enter the tenancy and user credentials.

2. Review and accept the terms and conditions.

3. Select the region where you want to deploy the stack.

4. Follow the on-screen prompts and instructions to create the stack.

5. After creating the stack, click **Terraform Actions**, and select **Plan**.

6. Wait for the job to be completed, and review the plan.

    To make any changes, return to the Stack Details page, click **Edit Stack**, and make the required changes. Then, run the **Plan** action again.

7. If no further changes are necessary, return to the Stack Details page, click **Terraform Actions**, and select **Apply**.

## Deploy Using the Terraform CLI
### Clone the Module
Now, you'll want a local copy of this repo. You can make that with the commands:

    git clone https://github.com/oracle-quickstart/oci-cloud-native-sftp.git
    cd oci-cloud-native-sftp
    ls

### Set Up and Configure Terraform
1. Complete the prerequisites described [here](https://github.com/cloud-partners/oci-prerequisites).
2. Configure the Terraform's [OCI Provider](https://registry.terraform.io/providers/hashicorp/oci/latest/docs) using [Environment Variables](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraformproviderconfiguration.htm#environmentVariables). The required variables are:
   - `TF_VAR_region`
   - `TF_VAR_tenancy_ocid`
   - `TF_VAR_user_ocid`
   - `TF_VAR_fingerprint`
   - `TF_VAR_private_key_path`
3. Create a `terraform.tfvars` file, and specify the following variables:
```
# Region of the Tenancy
region = "<region>"

# OCID of the Tenancy
tenancy_ocid = "<tenancy_ocid>"

# The user OCID (https://docs.cloud.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#five)
user_ocid = "<user_ocid>"

# OCID of the compartment where creating network resources
network_compartment_id = "<network_compartment_id>"

# OCID of the VCN to use for configuring a Cloud Native SFTP
# Required when using an existing VCN
vcn_id = "<vcn_id>"

# OCID of the subnet (public) where the Network Load Balancer is instantiated
# Required when using an existing VCN
lb_subnet_id = "<lb_subnet_id>"

# OCID of the subnet (private) where SFTP servers are instantiated
# Required when using an existing VCN
servers_subnet_id = "<servers_subnet_id>"

# The CIDR of the VCN to create for configuring a Cloud Native SFTP
# Required when using a new VCN
vcn_cidr         = "<vcn_cidr>"

# The CIDR of the subnet (public) to create for the Network Load Balancer
# Required when using a new VCN
lb_subnet_cidr   = "<lb_subnet_cidr>"

# The CIDR of the subnet (private) to create for the SFTP servers
# Required when using a new VCN
servers_subnet_cidr = "<servers_subnet_cidr>"

# OCID of the compartment designated for S3 Compatibility API
s3_compatibility_compartment_id	= "<s3_compatibility_compartment_id>"

# The name of the bucket, in designated S3 Compatibility compartment, where to store files
bucket_name = "<bucket_name>"

# OCID of the compartment where creating the Network Load Balancer
lb_compartment_id = "<lb_compartment_id>"

# OCID of the compartment where creating the SFTP servers
servers_compartment_id = "<servers_compartment_id>"

# The OCID of the image used for SFTP servers Compute instances
servers_image_id = "<servers_image_id>"

# The number of SFTP servers to istantiate
servers_count = "<servers_count>"

# The public key, in OpenSSH format, allowed for connecting to SFTP servers Compute instances through SSH
servers_ssh_authorized_keys="<servers_ssh_authorized_keys>"

# The name of the SFTP user
sftp_user_name = "<sftp_user_name>"

# The public key, in OpenSSH format, allowed for connecting to SFTP
sftp_user_ssh_authorized_keys="<sftp_user_ssh_authorized_keys>"

# OCID of the compartment where creating OCI Notifications and Events resources
notifications_compartment_id = "<notifications_compartment_id>"

# The mail recipient of the messages about SFTP files changes
notifications_email = "<notifications_email>"
````

### Create the resources
Run the following commands:

    terraform init
    terraform plan
    terraform apply

### Destroy the deployment
When you no longer need the deployment, you can run this command to destroy the resources:

    terraform destroy

## Deployment Notes
If you select to use existing VCN and subnets, please be sure that:
- The Route Table attached to the Load Balancer subnet is configured to enable access from Internet
- The Route Table attached to the SFTP Servers subnet is configured to enable access to Internet, because:
  - SFTP Servers bootstrap requires [s3fs](https://github.com/s3fs-fuse/s3fs-fuse) installation
  - SFTP Servers access to Object Storage for storing the files

  If Oracle Linux images are used for SFTP Servers, a [Service Gateway](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/servicegateway.htm#Access_to_Oracle_Services_Service_Gateway) is enough, otherwise a [NAT Gateway](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/NATgateway.htm#NAT_Gateway) is required.

For further information about Route Tables, take a look at [VCN Route Tables](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/managingroutetables.htm).