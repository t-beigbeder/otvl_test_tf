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

module "prlb_ubuntu" {
  source = "../../../modules/utils/get_ami"
  ami_name_regex = "ubuntu-jammy-22.04-amd64-server"
  ami_owner = "099720109477"
}

module "prlb_amz2" {
  source = "../../../modules/utils/get_ami"
  ami_name_regex = "amzn2-ami-amd"
  ami_owner = ""
}
