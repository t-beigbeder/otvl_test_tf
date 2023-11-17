terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.22"
    }
  }
}

module "m1_alb" {
  source = "./m1_alb"
  application_code = var.application_code
  env_name = var.env_name
  project_name = var.project_name
  resource_tags = var.resource_tags
  subnets_name_filter = var.asg_subnets_name_filter
  alb_domain_name = var.alb_domain_name
  alb_ingress_cidrs = var.alb_ingress_cidrs
  alb_ingress_port = var.alb_ingress_port
  alb_egress_port = var.alb_egress_port
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
  subnets_name_filter = var.asg_subnets_name_filter
  alb_private_ec2_security_group_id = module.m1_alb.alb_private_ec2_security_group.id
  alb_target_group_arn = module.m1_alb.alb_target_group.arn
  min_size = var.min_size
  max_size = var.max_size
}
