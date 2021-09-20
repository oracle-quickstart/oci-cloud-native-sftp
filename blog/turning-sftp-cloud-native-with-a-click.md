# Turning SFTP Cloud Native...with a click
As you have seen in the [_Turning SFTP Cloud Native_](https://blogs.oracle.com/cloud-infrastructure/post/turning-sftp-cloud-native) blog post, with a bit of imagination is possible to get your file-based integration rid of dust and design a fresh and polished, whilst fully backward compatible, Cloud Native SFTP solution leveraging on [OCI](https://www.oracle.com/cloud/).

Someone can point out that it was just theory, moving from a fancy architecture to a running solution it's another story.

Indeed that's true somehow, because such solution involves multiple components therefore several infrastructure provisioning and configuration activities are required.

But one of the never enough praised capabilities enabled by Cloud technologies is Infrastructure as Code, soothing from manual processes associated to infrastructure provisioning, configuration and management: using the [OCI Terraform Provider](https://registry.terraform.io/providers/hashicorp/oci/latest/docs) and [OCI Resource Manager](https://blogs.oracle.com/developers/post/iac-in-the-cloud-getting-started-with-resource-manager) creating a Cloud Native SFTP cannot be easier.

If you just want to see your Cloud Native SFTP running, just click on the [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://github.com/Oracle-CEG-CN/cloud-native-sftp) button you can find at [cloud-native-sftp](https://github.com/Oracle-CEG-CN/cloud-native-sftp) GitHub repository.

Instead if you want to know the technical details, don't stop reading.

## Cloud Native SFTP briefing
The main components of a Cloud Native SFTP solution are:
1. A [Network Load Balancer](https://docs.oracle.com/en-us/iaas/Content/NetworkLoadBalancer/home.htm) for distributing user sessions over the SFTP server instances
2. A set of [Compute](https://docs.oracle.com/en-us/iaas/Content/Compute/Concepts/computeoverview.htm) nodes acting as SFTP server instances
3. An [Object Storage](https://docs.oracle.com/en-us/iaas/Content/Object/Concepts/objectstorageoverview.htm) [bucket](https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/managingbuckets.htm) for sharing the files among the SFTP server instances

Additionally, using [Events](https://docs.oracle.com/en-us/iaas/Content/Events/Concepts/eventsgetstarted.htm) you can get updates when a file is uploaded, modified or deleted.

In order to get everything working, a lot of boring, and sometimes not trivial, tasks are required:
1. Create the network where the [Network Load Balancer](https://docs.oracle.com/en-us/iaas/Content/NetworkLoadBalancer/home.htm) and the [Compute](https://docs.oracle.com/en-us/iaas/Content/Compute/Concepts/computeoverview.htm) instances are deployed. Alternatively existing VCN and subnets can be used, but in any case the network configuration has to match some specific requirements
   - The [Network Load Balancer](https://docs.oracle.com/en-us/iaas/Content/NetworkLoadBalancer/home.htm) subnet must be public, with a [Security List](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/securitylists.htm) that enables TCP traffic on port `22` from any source
   - The SFTP servers subnet should be private, with a [Security List](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/securitylists.htm) that enables TCP traffic on port `22` from at least the [Network Load Balancer](https://docs.oracle.com/en-us/iaas/Content/NetworkLoadBalancer/home.htm) subnet
   - SFTP servers require connection to [Object Storage](https://docs.oracle.com/en-us/iaas/Content/Object/Concepts/objectstorageoverview.htm), moreover Internet access is needed for installing some software packages
      - If your [Compute](https://docs.oracle.com/en-us/iaas/Content/Compute/Concepts/computeoverview.htm) instances use an [Oracle Linux image](https://docs.oracle.com/en-us/iaas/images/all/?search=Oracle+Linux), having a [Service Gateway](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/servicegateway.htm) attached to SFTP servers subnet is enough. Through a [Service Gateway](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/servicegateway.htm) you can access both to [Object Storage](https://docs.oracle.com/en-us/iaas/Content/Object/Concepts/objectstorageoverview.htm) and regional [yum mirrors](https://yum.oracle.com/getting-started.html) hosted by OCI
      - Otherwise a [NAT Gateway](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/NATgateway.htm) needs to be attached to SFTP servers subnet, because the required software packages for others Linux distributions are available in repositories _external_ to OCI
2. Create the [Object Storage](https://docs.oracle.com/en-us/iaas/Content/Object/Concepts/objectstorageoverview.htm) [bucket](https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/managingbuckets.htm) where files are going to be stored
   - The [objects](https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/managingobjects.htm) within the [bucket](https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/managingbuckets.htm) have to be configured for emitting [events](https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/managingbuckets.htm#Events)
3. Create a [Customer Secret Key](https://docs.public.oneportal.content.oci.oraclecloud.com/en-us/iaas/Content/Identity/Tasks/managingcredentials.htm#To4) for accessing Object Storage using [S3 Compatibility API](https://docs.public.oneportal.content.oci.oraclecloud.com/en-us/iaas/Content/Object/Tasks/s3compatibleapi.htm)
4. Create and configure the [Compute](https://docs.oracle.com/en-us/iaas/Content/Compute/Concepts/computeoverview.htm) instances used for running SFTP servers
   - Mounting [Object Storage](https://docs.oracle.com/en-us/iaas/Content/Object/Concepts/objectstorageoverview.htm) [bucket](https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/managingbuckets.htm) using [s3fs](https://github.com/s3fs-fuse/s3fs-fuse)
   - Instances have to share the same [HostKey](https://man.openbsd.org/sshd_config#HostKey) to avoid issues with SFTP clients
   - SFTP user creation and enablement for secure access to shared files
5. Create the [Network Load Balancer](https://docs.oracle.com/en-us/iaas/Content/NetworkLoadBalancer/home.htm) for SFTP user session distribution
   - The [Compute](https://docs.oracle.com/en-us/iaas/Content/Compute/Concepts/computeoverview.htm) instances need to be added as backend to the [Network Load Balancer](https://docs.oracle.com/en-us/iaas/Content/NetworkLoadBalancer/home.htm)
6. Subscribe to meaningful [events](https://docs.oracle.com/en-us/iaas/Content/Events/Reference/eventsproducers.htm#ObjectStor) published when something occurs in your shared bucket

The Cloud Native SFTP resources can be created in a really simple and straightforward way thanks to the [OCI Terraform Provider](https://registry.terraform.io/providers/hashicorp/oci/latest/docs), also supporting _conditional logic_ based on the provided input variables. For example, as discussed the required network resources can be created from scratch or just reusing existing ones.

The trickiest part is the SFTP servers configuration. While the creation of the [Compute](https://docs.oracle.com/en-us/iaas/Content/Compute/Concepts/computeoverview.htm) instances is just about selecting the right options, their _inizialization_ require additional tooling.

The industry standard multi-distribution method for cross-platform cloud instance initialization, supported across all major public cloud providers thus available out-of-the-box within OCI [platform images](https://docs.oracle.com/en-us/iaas/Content/Compute/References/images.htm#OracleProvided_Images), is [`cloud-init`](https://cloudinit.readthedocs.io/en/latest/).

## Bootstrapping with `cloud-init`
[`cloud-init`](https://cloudinit.readthedocs.io/en/latest/) automates the initialization of cloud instances during system boot. It can be configured to perform tasks like:
- Creating users and groups
- Installing packages
- Write files

[`cloud-init`](https://cloudinit.readthedocs.io/en/latest/) uses YAML-formatted file instructions to perform tasks:
- When a [Compute](https://docs.oracle.com/en-us/iaas/Content/Compute/Concepts/computeoverview.htm) instance boots, the [`cloud-init`](https://cloudinit.readthedocs.io/en/latest/) service starts and searches for and executes the instructions
- Tasks complete during the first boot or on subsequent boots of your [Compute](https://docs.oracle.com/en-us/iaas/Content/Compute/Concepts/computeoverview.htm) instances

For configuring the [Compute](https://docs.oracle.com/en-us/iaas/Content/Compute/Concepts/computeoverview.htm) instances to run SFTP servers with the required configuration, the following [`cloud-init`](https://cloudinit.readthedocs.io/en/latest/) modules are used:
- [Users and Groups](https://cloudinit.readthedocs.io/en/latest/topics/modules.html#users-and-groups) for creating the SFTP user and group and [Compute](https://docs.oracle.com/en-us/iaas/Content/Compute/Concepts/computeoverview.htm)'s instance default user
- [SSH](https://cloudinit.readthedocs.io/en/latest/topics/modules.html#ssh) for configuring the same SSH host keys on every [Compute](https://docs.oracle.com/en-us/iaas/Content/Compute/Concepts/computeoverview.htm) instance
- [Write Files](https://cloudinit.readthedocs.io/en/latest/topics/modules.html#write-files) for copying the customized SSH server configuration and the installation/configuration script for mounting [Object Storage](https://docs.oracle.com/en-us/iaas/Content/Object/Concepts/objectstorageoverview.htm) [bucket](https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/managingbuckets.htm) using [s3fs](https://github.com/s3fs-fuse/s3fs-fuse)
- [Runcmd](https://cloudinit.readthedocs.io/en/latest/topics/modules.html#runcmd) for running the [s3fs](https://github.com/s3fs-fuse/s3fs-fuse) installation and configuration script

### SSH server configuration
Usually by default SFTP is not enabled in SSH server configuration, therefore the `sshd_config` file needs to be updated to included SFTP configuration:

    Subsystem sftp internal-sftp
    Match Group sftp
    ChrootDirectory /mnt/sftp/%u
    ForceCommand internal-sftp

The `Match Group` keyword is a conditional block: the subsequent keywords are applied only if the user being authenticated belongs to `sftp` group.

A [`chroot`](https://en.wikipedia.org/wiki/Chroot) is performed after the authentication, to enforce a proper resources isolation. Is important to note that `/mnt/sftp/%u` directory, where `%u` is the username, must be root-owned and not writable by any other user or group.

Since Terraform [TLS provider](https://github.com/hashicorp/terraform-provider-tls) support for [Ed25519](https://en.wikipedia.org/wiki/EdDSA#Ed25519) certificates is [misssing](https://github.com/hashicorp/terraform-provider-tls/issues/26), the SSH server should be configured to use only RSA and ECDSA keys:

    HostKey /etc/ssh/ssh_host_rsa_key
    HostKey /etc/ssh/ssh_host_ecdsa_key

The server's private keys are generated by Terraform, then copied to the [Compute](https://docs.oracle.com/en-us/iaas/Content/Compute/Concepts/computeoverview.htm) instances by [`cloud-init`](https://cloudinit.readthedocs.io/en/latest/) using the [SSH](https://cloudinit.readthedocs.io/en/latest/topics/modules.html#ssh) module.

### SFTP directories
Due to the [`chroot`](https://en.wikipedia.org/wiki/Chroot) directory permission requirements, for enabling the SFTP user to create files and directories we need to create a subdirectory (let's call it `private`) within, assigning to it read/write permissions for the SFTP user.

Assuming that SFTP username is `foo`:
- `/mnt/sftp/foo` is owned by `root:root`, the `foo` user has no write permissions
- `/mnt/sftp/foo/private` is owned by `foo:sftp`, the `foo` user has full write permissions 

The creation of SFTP directories is done by the _bootstrap script_ run by [`cloud-init`](https://cloudinit.readthedocs.io/en/latest/) using the [Runcmd](https://cloudinit.readthedocs.io/en/latest/topics/modules.html#runcmd) module.

### Mounting the bucket
The SFTP server instances enable access to the same shared [Object Storage](https://docs.oracle.com/en-us/iaas/Content/Object/Concepts/objectstorageoverview.htm) [bucket](https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/managingbuckets.htm), mounting it as filesystem using [s3fs](https://github.com/s3fs-fuse/s3fs-fuse).

After installing [s3fs](https://github.com/s3fs-fuse/s3fs-fuse), the following configuration activities are required:
1. Creation of file `/etc/s3fs/oci_passwd` for storing [S3 Compatibility API](https://docs.public.oneportal.content.oci.oraclecloud.com/en-us/iaas/Content/Object/Tasks/s3compatibleapi.htm) credentials
2. Adding the required instruction to `/etc/fstab` to enable automatic mounting of the [bucket](https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/managingbuckets.htm)

The instruction added to `/etc/fstab` is like the following:

    s3fs#<bucket-name> /mnt/sftp/<sftp-user> fuse _netdev,allow_other,use_path_request_style,passwd_file=/etc/s3fs/oci_passwd,url=https://<bucket-namespace>.compat.objectstorage.<oci-region>.oraclecloud.com/ 0 0

Where:
- &lt;bucket-name&gt; is the name of the [bucket](https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/managingbuckets.htm)
- _&lt;sftp-user&gt;_ is the username of the SFTP user
- _&lt;sftp-user&gt;_ is the username of the SFTP user
- _&lt;bucket-namespace&gt;_ is the [Object Storage](https://docs.oracle.com/en-us/iaas/Content/Object/Concepts/objectstorageoverview.htm) [namespace](https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/understandingnamespaces.htm#Understanding_Object_Storage_Namespaces)
- _&lt;oci-region&gt;_ is the name of the OCI Region. For example, `eu-frankfurt-1`

The [s3fs](https://github.com/s3fs-fuse/s3fs-fuse) installation and the configuration required for mounting the [Object Storage](https://docs.oracle.com/en-us/iaas/Content/Object/Concepts/objectstorageoverview.htm) [bucket](https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/managingbuckets.htm) are executed by the _bootstrap script_ run by [`cloud-init`](https://cloudinit.readthedocs.io/en/latest/) using the [Runcmd](https://cloudinit.readthedocs.io/en/latest/topics/modules.html#runcmd) module.

## Be aware of updates
Just to get noticed when a file is upload to your Cloud Native SFTP, the [events](https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/managingbuckets.htm#Events) emitted by the [Object Storage](https://docs.oracle.com/en-us/iaas/Content/Object/Concepts/objectstorageoverview.htm) [bucket](https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/managingbuckets.htm), there is a [Notifications](https://docs.oracle.com/en-us/iaas/Content/Notification/Concepts/notificationoverview.htm) [subscription](https://docs.oracle.com/en-us/iaas/Content/Notification/Tasks/managingtopicsandsubscriptions.htm) configured for sending an e-mail when actions occur on the files shared through SFTP.

Of course that's just a simple example to see with your eyes that everything is working as expected...and promised. As discussed, actions for reacting to [Object Storage](https://docs.oracle.com/en-us/iaas/Content/Object/Concepts/objectstorageoverview.htm) [events](https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/managingbuckets.htm#Events) can be implemented using [Streaming](hhttps://docs.oracle.com/en-us/iaas/Content/Streaming/Concepts/streamingoverview.htm) or [Functions](https://docs.oracle.com/en-us/iaas/Content/Functions/Concepts/functionsoverview.htm#Overview_of_Functions). Moreover, also a different [Notifications](https://docs.oracle.com/en-us/iaas/Content/Notification/Concepts/notificationoverview.htm) [subscription](https://docs.oracle.com/en-us/iaas/Content/Notification/Tasks/managingtopicsandsubscriptions.htm), like Slack or a custom HTTPS endpoint, can be used.

## Deployment
Rather than deploy your Cloud Native SFTP using the Terraform CLI, it's definitely easier to do it using [Oracle Resource Manager](https://docs.oracle.com/en-us/iaas/Content/ResourceManager/Concepts/resourcemanager.htm):
1. Click [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?region=home&zipUrl=https://github.com/Oracle-CEG-CN/cloud-native-sftp/releases/download/v1.0.0/cloud-native-sftp-stack-v1.0.0.zip)

    If you aren't already signed in, when prompted, enter the tenancy and user credentials.

2. Review and accept the terms and conditions.

3. Select the region where you want to deploy the stack.

4. Follow the on-screen prompts and instructions to create the stack.

5. After creating the stack, click **Terraform Actions**, and select **Plan**.

6. Wait for the job to be completed, and review the plan.

    To make any changes, return to the Stack Details page, click **Edit Stack**, and make the required changes. Then, run the **Plan** action again.

7. If no further changes are necessary, return to the Stack Details page, click **Terraform Actions**, and select **Apply**.

## I want to know more
As someone once said, [talk is cheap](https://lkml.org/lkml/2000/8/25/132). If you want to see the code, you can find it within the [cloud-native-sftp](https://github.com/Oracle-CEG-CN/cloud-native-sftp) GitHub repository. Of course, we can also discuss it further if required.