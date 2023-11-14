
terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.22"
    }
  }
}

module "m2_ec2_role" {
  source = "./m2_ec2_role"
  application_code = var.application_code
  env_name = var.env_name
  project_name = var.project_name
  resource_tags = var.resource_tags
  ec2_mandatory_policy_name = var.ec2_mandatory_policy_name
}
/*
module "m4_asg" {
  source = "./m4_asg"
  application_code = var.application_code
  env_name = var.env_name
  project_name = var.project_name
  resource_tags = var.resource_tags
  ami_name_regex = var.ami_name_regex
  ami_owner = var.ami_owner
  instance_type = var.instance_type
  instance_has_ssh = var.instance_has_ssh
  instance_key_name = var.instance_has_ssh ? var.instance_key_name : null
  min_size = var.min_size
  max_size = var.max_size
}
*/