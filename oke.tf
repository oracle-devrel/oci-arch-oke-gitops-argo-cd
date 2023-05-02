## Copyright (c) 2021, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl


module "oci-oke" {
  count                                                                       = var.create_new_oke_cluster ? 1 : 0
  source                                                                      = "github.com/oracle-devrel/terraform-oci-arch-oke"
  tenancy_ocid                                                                = var.tenancy_ocid
  compartment_ocid                                                            = local.oke_compartment_id
  oke_cluster_name                                                            = "${var.app_name} (${random_string.deploy_id.result})"
  services_cidr                                                               = lookup(var.network_cidrs, "KUBERNETES-SERVICE-CIDR")
  pods_cidr                                                                   = lookup(var.network_cidrs, "PODS-CIDR")
  cluster_options_add_ons_is_kubernetes_dashboard_enabled                     = var.cluster_options_add_ons_is_kubernetes_dashboard_enabled
  cluster_options_add_ons_is_tiller_enabled                                   = false
  cluster_options_admission_controller_options_is_pod_security_policy_enabled = var.cluster_options_admission_controller_options_is_pod_security_policy_enabled
  cluster_type                                                                = var.cluster_type
  pool_name                                                                   = var.node_pool_name
  node_shape                                                                  = var.node_pool_shape
  node_ocpus                                                                  = var.node_pool_node_shape_config_ocpus
  node_memory                                                                 = var.node_pool_node_shape_config_memory_in_gbs
  node_count                                                                  = var.num_pool_workers
  node_pool_boot_volume_size_in_gbs                                           = var.node_pool_boot_volume_size_in_gbs
  k8s_version                                                                 = (var.k8s_version == "Latest") ? local.cluster_k8s_latest_version : var.k8s_version
  use_existing_vcn                                                            = true
  vcn_id                                                                      = oci_core_virtual_network.oke_vcn[0].id
  is_api_endpoint_subnet_public                                               = (var.cluster_endpoint_visibility == "Private") ? false : true
  api_endpoint_subnet_id                                                      = oci_core_subnet.oke_k8s_endpoint_subnet[0].id
  is_lb_subnet_public                                                         = true
  lb_subnet_id                                                                = oci_core_subnet.oke_lb_subnet[0].id
  is_nodepool_subnet_public                                                   = false
  nodepool_subnet_id                                                          = oci_core_subnet.oke_nodes_subnet[0].id
  ssh_public_key                                                              = var.generate_public_ssh_key ? tls_private_key.oke_worker_node_ssh_key.public_key_openssh : var.public_ssh_key
  availability_domain                                                         = data.oci_identity_availability_domains.ADs.availability_domains[0]["name"]
  defined_tags                                                                = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}



resource "oci_identity_compartment" "oke_compartment" {
  compartment_id = var.compartment_ocid
  name           = "oke-compartment-${random_string.deploy_id.result}"
  description    = "${var.oke_compartment_description} (Deployment ${random_string.deploy_id.result})"
  enable_delete  = true
  defined_tags   = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }

  count = var.create_new_compartment_for_oke ? 1 : 0
}
locals {
  #oke_compartment_id = var.create_new_compartment_for_oke ? oci_identity_compartment.oke_compartment.0.id : var.compartment_id
  oke_compartment_id = var.compartment_ocid
}

# Local kubeconfig for when using Terraform locally. Not used by Oracle Resource Manager
resource "local_file" "kubeconfig" {
  content  = data.oci_containerengine_cluster_kube_config.oke_cluster_kube_config.content
  filename = "/tmp/kubeconfig"
}

# Generate ssh keys to access Worker Nodes, if generate_public_ssh_key=true, applies to the pool
resource "tls_private_key" "oke_worker_node_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Get OKE options
locals {
  cluster_k8s_latest_version   = reverse(sort(data.oci_containerengine_cluster_option.oke.kubernetes_versions))[0]
  node_pool_k8s_latest_version = reverse(sort(data.oci_containerengine_node_pool_option.oke.kubernetes_versions))[0]
}

# Checks if is using Flexible Compute Shapes
locals {
  is_flexible_node_shape = contains(local.compute_flexible_shapes, var.node_pool_shape)
}


/*
resource "oci_containerengine_cluster" "oke_cluster" {
  compartment_id     = local.oke_compartment_id
  kubernetes_version = (var.k8s_version == "Latest") ? local.cluster_k8s_latest_version : var.k8s_version
  name               = "OKE-DevOps-Cluster-(${random_string.deploy_id.result})"
  vcn_id             = oci_core_virtual_network.oke_vcn[0].id

  endpoint_config {
    is_public_ip_enabled = (var.cluster_endpoint_visibility == "Private") ? false : true
    subnet_id            = oci_core_subnet.oke_k8s_endpoint_subnet[0].id
  }
  options {
    service_lb_subnet_ids = [oci_core_subnet.oke_lb_subnet[0].id]
    add_ons {
      is_kubernetes_dashboard_enabled = var.cluster_options_add_ons_is_kubernetes_dashboard_enabled
      is_tiller_enabled               = false # Default is false, left here for reference
    }
    admission_controller_options {
      is_pod_security_policy_enabled = var.cluster_options_admission_controller_options_is_pod_security_policy_enabled
    }
    kubernetes_network_config {
      services_cidr = lookup(var.network_cidrs, "KUBERNETES-SERVICE-CIDR")
      pods_cidr     = lookup(var.network_cidrs, "PODS-CIDR")
    }
  }
  # kms_key_id = var.use_encryption_from_oci_vault ? (var.create_new_encryption_key ? oci_kms_key.mushop_key[0].id : var.existent_encryption_key_id) : null

  count = var.create_new_oke_cluster ? 1 : 0
}

resource "oci_containerengine_node_pool" "oke_node_pool" {
  cluster_id         = oci_containerengine_cluster.oke_cluster[0].id
  compartment_id     = local.oke_compartment_id
  kubernetes_version = (var.k8s_version == "Latest") ? local.node_pool_k8s_latest_version : var.k8s_version
  name               = var.node_pool_name
  node_shape         = var.node_pool_shape
  ssh_public_key     = var.generate_public_ssh_key ? tls_private_key.oke_worker_node_ssh_key.public_key_openssh : var.public_ssh_key

  node_config_details {
    dynamic "placement_configs" {
      for_each = data.oci_identity_availability_domains.ADs.availability_domains

      content {
        availability_domain = placement_configs.value.name
        subnet_id           = oci_core_subnet.oke_nodes_subnet[0].id
      }
    }
    #size = var.cluster_autoscaler_enabled ? var.cluster_autoscaler_min_nodes : var.num_pool_workers
    size = var.num_pool_workers
  }

  dynamic "node_shape_config" {
    for_each = local.is_flexible_node_shape ? [1] : []
    content {
      ocpus         = var.node_pool_node_shape_config_ocpus
      memory_in_gbs = var.node_pool_node_shape_config_memory_in_gbs
    }
  }

  node_source_details {
    source_type             = "IMAGE"
    image_id                = lookup(data.oci_core_images.node_pool_images.images[0], "id")
    boot_volume_size_in_gbs = var.node_pool_boot_volume_size_in_gbs
  }

  initial_node_labels {
    key   = "name"
    value = var.node_pool_name
  }

  count = var.create_new_oke_cluster ? 1 : 0
}

*/
