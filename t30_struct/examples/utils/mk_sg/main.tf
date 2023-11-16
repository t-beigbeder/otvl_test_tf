provider "aws" {
  region = "eu-west-3"
}

terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version     = "5.23.1"
    }
  }
}

module "prlb_tags1" {
  source = "../../../modules/utils/get_tags"
  application_code = "b2a1"
  env_name         = "dev"
  project_name     = "theProject"
  resource_tags    = [
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
  tags = module.prlb_tags1.ready
}

module "prlb_sg_eg_all" {
  source = "../../../modules/utils/mk_sg"
  name   = "prlb_sg_eg_all"
  egress_allow_all = true
}
