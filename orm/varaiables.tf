## Copyright (c) 2022, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "tenancy_ocid" {
  default = ""
  }
variable "compartment_ocid" {
  default =  ""
}
variable "user_ocid" {
  default = ""
}
variable "fingerprint" {
  default = ""
}
variable "private_key_path" {
  default = ""
}
variable "region" {
  default = ""
}

variable "release" {
  description = "Reference Architecture Release (OCI Architecture Center)"
  default     = "1.0.4"
}

variable "cluster_type" {
  default = "enhanced"
}











/*
variable "registry_display_name" {
  default = "node-express-getting-starter"
}
*/

variable "container_repository_is_public" {
  default = true
}

variable "deploy_artifact_argument_substitution_mode" {
  default = "SUBSTITUTE_PLACEHOLDERS"
}

/*
variable "deploy_artifact_display_name" {
  default = "node-express-getting-starter"
}
*/




