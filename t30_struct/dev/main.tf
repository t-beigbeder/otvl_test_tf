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

  backend "s3" {
    bucket         = "default-tf-bucket"
    key            = "t30/dev/terraform.tfstate"
    region         = "eu-west-3"
    dynamodb_table = "default-tf-dynamo-table"
    encrypt        = true
  }

}

module "prereqs" {
  source = "../modules/prereqs"
  application_code = var.application_code
  default_tags = var.default_tags
}
