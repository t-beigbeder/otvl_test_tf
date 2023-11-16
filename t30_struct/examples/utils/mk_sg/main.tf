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

module "prlb_def_sg" {
  source = "../../../modules/utils/mk_sg"
  name   = "prlb_def_sg"
}

module "prlb_sg_eg_all" {
  source = "../../../modules/utils/mk_sg"
  name   = "prlb_sg_eg_all"
  egress_allow_all = true
}
