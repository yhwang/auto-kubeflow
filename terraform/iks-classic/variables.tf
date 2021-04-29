variable "ibmcloud_api_key" {
  description = "IBM Cloud API key when run standalone"
}
variable region {
  type    = string
  default = "us-south"
}

variable org {
  type        = string
  description = "The orgnization in IBM Cloud"
}

variable space {
  type        = string
  description = "The space in IBM Cloud"
}

variable kube_version {
  type        = string
  default     = "1.20.6"
  description = "kubectl version"
}

variable resource_group {
  type        = string
  default     = "default"
  description = "The resource group in IBM Cloud"
}

variable appid_plan {
  type        = string
  default     = "lite"
  #graduated-tier
  description = "plan for AppID"
}

variable appid_name {
  type        = string
  default     = "appid-instance"
  description = "Instnace name for AppID service"
}

variable appid_login_logo {
  type        = string
  default     = "https://avatars.githubusercontent.com/u/33164907?s=200&v=4"
  description = "The logo image of the AppID login page. Need to be a png image"
}

variable cluster_name {
  type        = string
  default     = "my-kfp-cluster"
  description = "cluster name"
}

variable cluster_worker_count {
  type        = number
  default     = 2
  description = "number of workers in the cluster"
}

variable cluster_worker_flavor {
  type        = string
  default     = "b3c.4x16"
  description = "worker flavor for the cluster"
}

variable "public_vlan_id" {
  default     = null
  type        = string
  description = "public vlan id, you can get it by 'ibmcloud ks vlans --zone <zone>'. this is needed by classic cluster"
}

variable "private_vlan_id" {
  default     = null
  type        = string
  description = "private vlan id, you can get it by 'ibmcloud ks vlans --zone <zone>'. this is needed by classic cluster"
}

variable "zone" {
  default     = "dal10"
  description = "The datacenter where you want to provision the worker nodes for classic cluster"
  type        = string
}
