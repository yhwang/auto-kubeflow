# auto-kubeflow
Use Schematics/Terraform + Ansible to create a classic cluster on IBM Cloud,
deploy kubeflow v1.3 multi-user and integrate it with AppID service. It uses the
kfdef here: "https://raw.githubusercontent.com/IBM/manifests/v1.3/distributions/kfdef/kfctl_ibm_multi_user.v1.3.0.yaml"

The terraform templates are under this directory and used to create classic
cluster as well as AppID instance. The kubeflow deployment and
configuration are done by Ansible playbook under `ansible` directory.
It uses [Ansible provisioner](https://github.com/radekg/terraform-provisioner-ansible)
to perform Ansilbe playbook.

Note: The Ansible playbook under `asnible` directory assumes the execution
environment is Linux x86_64 architecture. If you want to run it locally, you may need
to modify the playbook to accommodate your own environment.
## Inputs

| name | description | type | required | default | sensitive |
| ------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- | -------------- | ---------- | ------------------------------------ | ---- |
|  ibmcloud_api_key      | IBM API key to to login ibm cloud and create resources |  string |  ✓  |      | ✓ |
|  region                | The IBM Cloud regision you are going to create the resources | string  |   | us-south |  |
|  org                   | IBM Cloud organization | string  |  ✓ |  |  |
|  space                 | The space in IBM Cloud | string  | ✓ |  |  |
|  resource_group        | The resource group in IBM Cloud | string  |  | default |  |
|  kube_version          | kubernetes version | string  |  | 1.20.6 |  |
|  appid_plan            | The plan for AppID | string  |  | lite |  |
|  appid_name            | Instnace name for AppID service | string  |   | appid-instance |  |
|  cluster_name          | Cluster name | string  |   | my-kfp-cluster | |
|  cluster_worker_flavor | The machine flavor for the cluster worker nodes | string  |   | b3c.4x16 |  |
|  cluster_worker_count  | number of workers in the cluster | number  |   | 2 |  |
|  zone                  | The zone where the cluster will be created | string  |   | dal10 | |
|  public_vlan_id        | The id of public vlan | string  |   | | |
|  private_vlan_id       | The id of private vlan | string  |   | | |
|  appid_login_logo      | The logo image of the AppID login page. Need to be a png image | string  |   | https://avatars.githubusercontent.com/u/33164907?s=200&v=4 (kubeflow logo) | |

## Outputs

|  **name**      |    **description**  |
|  --------------------------------------- | ------------------------------------------- |
|  appid_id                | The id of AppID instance |
|  appid_discoveryEndpoint | The discovery endpoint of the AppID instance |
|  appid_tenantId          | The tenant id of the AppID instance |
|  appid_managementUrl     | The management API url of the AppID instance |
|  appid_oauthServerUrl    | The OAuth service Url |
|  cluster_id              | The id of the cluster |
|  cluster_name            | The name of the created cluster |
|  cluster_hostname        | The network load balancer hostname of the created cluster |


## Instructions
Create the Schematics provisioner workspace:
1. From the IBM Cloud menu select [Schematics](https://cloud.ibm.com/schematics/overview).
   - Click **Create workspace**.   
   - Enter a name for your workspace.   
   - Click **Create** to create your workspace.
2. On the workspace **Settings** page, enter the URL of this terraform
   template: `https://github.com/yhwang/auto-kubeflow/tree/main/terraform/iks_classic`.
   - Select the Terraform version: Terraform 0.14.
   - Click **Save template information**.
   - In the **Input variables** section,  fill in the input variables. For example:
     - `ibmcloud_api_key` IBM API key
     - `org` The organization of IBM Cloud
     - `space` The space of IBM Cloud
     - `zone` Where the new cluster will be created. You can use `ibmcloud ks zone ls --provider classic`
       to get the available zones
     - `public_vlan_id` The public vlan id. When you decide the datacenter, you can use `ibmcloud ks vlan ls --zone <datacenter>` to list the available public vlan
     - `private_vlan_id` The private vlan id. When you decide the datacenter, you can use `ibmcloud ks vlan ls --zone <datacenter>` to list the available private vlan

     Note: In order to make the kubeflow work properly, the flavor of `b3c.4x16`
     and 2 worker nodes are the minimal requirements.

   - Click **Save changes**.
3. From the workspace **Settings** page, click **Generate plan** 
4. Click **View log** to review the log files of your Terraform
    execution plan.
5. Apply your Terraform template by clicking **Apply plan**.
6. Review the log file to ensure that no errors occurred during the provisioning
   process.
7. Check the output of `cluster_hostname`. You should be able to access the
   kubeflow with the following url: `https://<cluster_hostname>`
