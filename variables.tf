## Copyright (c) 2021, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "tenancy_ocid" {
  
  }
variable "compartment_ocid" {
  
}
variable "user_ocid" {
  
}
variable "fingerprint" {
  
}
variable "private_key_path" {
  
}
variable "region" {
  
}

variable "cluster_type" {
  default = "enhanced"
}

variable "app_name" {
  default = "ArgoCD"
}


variable "release" {
  description = "Reference Architecture Release (OCI Architecture Center)"
  default     = "1.0.3"
}













