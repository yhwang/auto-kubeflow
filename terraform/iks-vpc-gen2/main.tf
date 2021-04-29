terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      version = "1.21.2"
    }
  }
}

provider "ibm" {
  # Configuration options
  region = var.region
  ibmcloud_api_key = var.ibmcloud_api_key
  generation = 2
}

resource "random_id" "suffix" {
  byte_length = 2
}

locals {
  name_suffix           = "-${random_id.suffix.hex}"
  kfdef_uri             = "https://raw.githubusercontent.com/IBM/manifests/v1.3/distributions/kfdef/kfctl_ibm_multi_user.v1.3.0.yaml"
  kube_version_str        = split(".", var.kube_version)
}

module "appid" {
  source               = "../modules/appid"
  ibmcloud_api_key     = var.ibmcloud_api_key
  region               = var.region
  name                 = var.appid_name
  plan                 = var.appid_plan
  name_suffix          = local.name_suffix
}

module "vpc_cluster" {
  source               = "../modules/vpc-gen2-cluster"
  ibmcloud_api_key     = var.ibmcloud_api_key
  region               = var.region
  space                = var.space
  org                  = var.org
  worker_count         = var.cluster_worker_count
  flavor               = var.cluster_worker_flavor
  resource_group       = var.resource_group
  cluster_name         = var.cluster_name
  kube_version         = "${local.kube_version_str[0]}.${local.kube_version_str[1]}"
  name_suffix          = local.name_suffix
  depends_on           = [ module.appid ]
}

data "ibm_container_cluster_config" "cluster_config" {
  cluster_name_id = module.vpc_cluster.cluster_id
}

resource "null_resource" "ansible" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "ansible" {
    plays {
      playbook {
        file_path  = "${path.module}/../ansible/multi-user-vpc.yml"
        roles_path = [ "${path.module}/../ansible/roles"]
      }
      inventory_file = "${path.module}/../ansible/inventory.yml"
      verbose = true
      extra_vars = {
        ibmcloud_api_key        = var.ibmcloud_api_key
        region                  = var.region
        org                     = var.org
        space                   = var.space
        resource_group          = var.resource_group
        appid_clientId          = module.appid.clientId
        appid_secret            = module.appid.secret
        appid_oauthServerUrl    = module.appid.oauthServerUrl
        appid_id                = module.appid.appid_id
        kubectl_ver             = "v${var.kube_version}"
        appid_mgmt_url          = module.appid.managementUrl
        cluster_hostname        = module.vpc_cluster.cluster_hostname
        cluster_name            = module.vpc_cluster.cluster_name
        secret_name             = module.vpc_cluster.cluster_secret
        kube_config             = data.ibm_container_cluster_config.cluster_config.config_file_path
        kfdef_uri               = local.kfdef_uri
        kubeflow_logo_uri       = var.appid_login_logo
      }
    }
  }
  depends_on = [module.vpc_cluster]
}
