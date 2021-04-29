terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      version = "1.21.2"
    }
  }
}

resource "ibm_is_vpc" "vpc" {
  name = "vpc${var.name_suffix}"
}

resource "ibm_is_public_gateway" "public_gateway" {
    name = "public-gateway${var.name_suffix}"
    vpc = ibm_is_vpc.vpc.id
    zone = "${var.region}-1"
}

resource "ibm_is_subnet" "subnet" {
  name                     = "subnet${var.name_suffix}"
  vpc                      = ibm_is_vpc.vpc.id
  public_gateway           = ibm_is_public_gateway.public_gateway.id
  zone                     = "${var.region}-1"
  total_ipv4_address_count = 32
}

data "ibm_resource_group" "resource_group" {
  name = var.resource_group
}

resource "null_resource" "update_default_sg" {
  provisioner "local-exec" {
    command = <<EOF
        ibmcloud config --check-version=false
        ibmcloud login --apikey ${var.ibmcloud_api_key} --no-region
        ibmcloud target -r "${var.region}" -o "${var.org}" -s "${var.space}" -g "${var.resource_group}"
        ibmcloud is security-group-rule-update ${ibm_is_vpc.vpc.default_security_group} ${ibm_is_vpc.vpc.security_group[0].rules[0].rule_id} --direction ${ibm_is_vpc.vpc.security_group[0].rules[0].direction} --remote "0.0.0.0/0"
        ibmcloud is security-group-rule-update ${ibm_is_vpc.vpc.default_security_group} ${ibm_is_vpc.vpc.security_group[0].rules[1].rule_id} --direction ${ibm_is_vpc.vpc.security_group[0].rules[1].direction} --remote "0.0.0.0/0"
EOF

  }
}

resource "ibm_container_vpc_cluster" "cluster" {
  name              = "${var.cluster_name}${var.name_suffix}"
  vpc_id            = ibm_is_vpc.vpc.id
  kube_version      = var.kube_version
  flavor            = var.flavor
  worker_count      = var.worker_count
  resource_group_id = data.ibm_resource_group.resource_group.id
  wait_till         = var.cluster_wait_til

  zones {
    subnet_id = ibm_is_subnet.subnet.id
    name      = "${var.region}-1"
  }

  depends_on = [
    null_resource.update_default_sg
  ]
}
