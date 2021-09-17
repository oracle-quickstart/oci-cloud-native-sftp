# cloud-native-sftp
Have you ever wondered how to turn a legacy, but still widely adopted, solution like SFTP into a fresh Cloud Native solution ?

That's a Terraform module for [_Turning SFTP Cloud Native_](https://blogs.oracle.com/cloud-infrastructure/post/turning-sftp-cloud-native).

## Deploy Using Oracle Resource Manager

1. Click [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?region=home&zipUrl=https://github.com/Oracle-CEG-CN/cloud-native-sftp/releases/download/v1.1.0/cloud-native-sftp-stack-v1.1.0.zip)

    If you aren't already signed in, when prompted, enter the tenancy and user credentials.

2. Review and accept the terms and conditions.

3. Select the region where you want to deploy the stack.

4. Follow the on-screen prompts and instructions to create the stack.

5. After creating the stack, click **Terraform Actions**, and select **Plan**.

6. Wait for the job to be completed, and review the plan.

    To make any changes, return to the Stack Details page, click **Edit Stack**, and make the required changes. Then, run the **Plan** action again.

7. If no further changes are necessary, return to the Stack Details page, click **Terraform Actions**, and select **Apply**.