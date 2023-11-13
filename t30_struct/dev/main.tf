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
  env_name = var.env_name
  project_name = var.project_name
  resource_tags = var.resource_tags
  app_has_infra_bucket = var.app_has_infra_bucket
}

module "alb_asg_sample" {
  source = "../modules/alb_asg_sample"
  application_code = var.application_code
  env_name = var.env_name
  project_name = var.project_name
  resource_tags = var.resource_tags
  instance_type = var.ec2_lb_instance_type
  instance_has_ssh = var.ec2_lb_instance_has_ssh
  instance_key_name = var.ec2_lb_instance_has_ssh ? var.ec2_lb_instance_key_name : null
  min_size = var.min_size
  max_size = var.max_size
}

/*
module "ec2_admin_sample" {
  source = "../modules/ec2_admin_sample"
  application_code = var.application_code
  env_name = var.env_name
  project_name = var.project_name
  resource_tags = var.resource_tags
  instance_type = var.ec2_admin_instance_type
}
*/
