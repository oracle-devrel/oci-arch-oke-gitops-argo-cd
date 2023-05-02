# OCI-OKE-ArgoCD

## Introduction

This Terraform code will allow you deploy Argo CD to an existing OKE cluster or new OKE cluster.

## Terraform Provider for Oracle Cloud Infrastructure
The OCI Terraform Provider is now available for automatic download through the Terraform Provider Registry. 
For more information on how to get started view the [documentation](https://www.terraform.io/docs/providers/oci/index.html) 
and [setup guide](https://www.terraform.io/docs/providers/oci/guides/version-3-upgrade.html).

* [Documentation](https://www.terraform.io/docs/providers/oci/index.html)
* [OCI forums](https://cloudcustomerconnect.oracle.com/resources/9c8fa8f96f/summary)
* [Github issues](https://github.com/terraform-providers/terraform-provider-oci/issues)
* [Troubleshooting](https://www.terraform.io/docs/providers/oci/guides/guides/troubleshooting.html)

## Deploy Using Oracle Resource Manager


1. Click [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?region=home&zipUrl=https://github.com/oracle-devrel/oci-arch-oke-gitops-argo-cd/archive/refs/tags/v2.zip)


## Deploy Using the Terraform CLI

### Clone the Module

Now, you'll want a local copy of this repo. You can make that with the commands:

    git clone https://github.com/oracle-devrel/oci-arch-oke-gitops-argo-cd
    cd oci_arch-oke-gitops-argo-cd
    ls

### Prerequisites

First off, you'll need to do some pre-deploy setup.  That's all detailed [here](https://github.com/cloud-partners/oci-prerequisites).


```
# Authentication
tenancy_ocid         = "<tenancy_ocid>"
user_ocid            = "<user_ocid>"
fingerprint          = "<finger_print>"
private_key_path     = "<pem_private_key_path>"

# Region
region = "<oci_region>"

# Compartment
compartment_ocid = "<compartment_ocid>"

# oke-variables
existent_oke_cluster_id = "ocid_of_Oke_cluster_to_deploy_helm "

````

Deploy:

    terraform init
    terraform plan
    terraform apply


## Destroy the Deployment
When you no longer need the deployment, you can run this command to destroy it:

    terraform destroy

Note: Application deployment within OKE will lead to OCI LoadBalancer provisioning, created outside the Terraform realm. Consequently, terraform destroy operation will not be able to destroy OKE as dependent LB will stay untouched. Therefore you should destroy LB from OCI Console perspective beforehand. Then you can continue with terraform destroy command.

