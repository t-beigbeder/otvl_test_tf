
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
  kms_key_for_infra_arn = var.kms_key_for_infra_arn
  ec2_mandatory_policy_name = var.ec2_mandatory_policy_name
}

module "m4_asg" {
  source = "./m4_asg"
  application_code = var.application_code
  env_name = var.env_name
  project_name = var.project_name
  resource_tags = var.resource_tags
  ami_name_regex = var.ami_name_regex
  ami_owner = var.ami_owner
  instance_type = var.instance_type
  instance_ssh_key_name = var.instance_ssh_key_name
  instance_user_data = var.instance_user_data
  ec2_mandatory_sg_name = var.ec2_mandatory_sg_name
  min_size = var.min_size
  max_size = var.max_size
}
