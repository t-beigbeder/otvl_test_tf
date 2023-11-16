provider "aws" {
  region = "eu-west-3"
}

terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.23.1"
    }
  }
}

module "prlb_tags1" {
  source           = "../../../modules/utils/get_tags"
  application_code = "b2a1"
  env_name         = "dev"
  project_name     = "theProject"
  resource_tags = [
    {
      key                 = "managed-by"
      is_constant         = true
      constant            = "opentofu"
      is_application_code = false
      is_env_name         = false
      is_project_name     = false
    },
    {
      key                 = "corp:application_code"
      is_constant         = false
      is_application_code = true
      is_env_name         = false
      is_project_name     = false
    },
    {
      key                 = "corp:environment"
      is_constant         = false
      is_application_code = false
      is_env_name         = true
      is_project_name     = false
    }
  ]
}

module "prlb_def_sg" {
  source = "../../../modules/utils/mk_sg"
  name   = "prlb_def_sg"
  tags   = module.prlb_tags1.tags
}

module "prlb_sg_eg_all" {
  source           = "../../../modules/utils/mk_sg"
  name             = "prlb_sg_eg_all"
  egress_allow_all = true
}

module "prlb_sg_eg_to_eg_all" {
  source = "../../../modules/utils/mk_sg"
  name   = "prlb_sg_eg_to_eg_all"
  egress_rules = [
    {
      from_port          = 0
      to_port            = 0
      protocol           = "-1"
      cidr_blocks        = []
      ipv6_cidr_blocks   = []
      security_group_ids = [module.prlb_sg_eg_all.security_group.id]
    }
  ]
}

module "prlb_sg_in_http" {
  source = "../../../modules/utils/mk_sg"
  name   = "prlb_sg_in_http"
  ingress_rules = [
    {
      from_port          = 80
      to_port            = 80
      protocol           = "tcp"
      cidr_blocks        = ["0.0.0.0/0"]
      ipv6_cidr_blocks   = []
      security_group_ids = []
    },
    {
      from_port          = 443
      to_port            = 443
      protocol           = "tcp"
      cidr_blocks        = []
      ipv6_cidr_blocks   = ["::/0"]
      security_group_ids = []
    },
    {
      from_port          = 22
      to_port            = 22
      protocol           = "tcp"
      cidr_blocks        = []
      ipv6_cidr_blocks   = []
      security_group_ids = [module.prlb_sg_eg_all.security_group.id]
    }
  ]
}

locals {
  iips = ["192.168.128.22", "192.168.128.48"]
  irules = [
    for iip in local.iips : {
      from_port          = 443
      to_port            = 443
      protocol           = "tcp"
      cidr_blocks        = ["${iip}/32"]
      ipv6_cidr_blocks   = []
      security_group_ids = []
    }
  ]
}

module "prlb_sg_in_https_v1" {
  source = "../../../modules/utils/mk_sg"
  name   = "prlb_sg_in_https_v1"
  ingress_rules = local.irules
}
