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

module "prlb_subnets_sub" {
  source = "../../../modules/utils/get_subnets"
  subnets_name_filter = "sub"
  vpc_is_default = true
}

module "prlb_subnets_a" {
  source = "../../../modules/utils/get_subnets"
  subnets_name_filter = "default-a"
  vpc_is_default = true
}
