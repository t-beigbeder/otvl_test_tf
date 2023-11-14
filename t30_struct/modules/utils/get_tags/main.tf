terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.22"
    }
  }
}

locals {
  ctags = {
    for vt in var.resource_tags : vt.key => vt.constant
    if vt["is_constant"]
  }
  atags = {
    for vt in var.resource_tags : vt.key => lower(var.application_code)
    if vt.is_application_code
  }
  etags = {
    for vt in var.resource_tags : vt.key => lower(var.env_name)
    if vt.is_env_name
  }
  ptags = {
    for vt in var.resource_tags : vt.key => lower(var.project_name)
    if vt.is_project_name
  }
}
