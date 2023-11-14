terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.22"
    }
  }
}

module "get_ami" {
  source         = "../../utils/get_ami"
  ami_name_regex = var.ami_name_regex
  ami_owner      = var.ami_owner
}

locals {
  init_user_data = <<-EOF
    application_code=${var.application_code}
    env_name=${var.env_name}
  EOF
}

resource "aws_iam_instance_profile" "this" {
  name = "InstanceProfileRoleMandatoryWithS3-${lower(var.application_code)}-${lower(var.env_name)}"
  role = "roleEC2toS3andKMSandEFS-${lower(var.application_code)}-${lower(var.env_name)}"
}

resource "aws_launch_template" "this" {
  update_default_version = true
  name                   = "lt-${lower(var.application_code)}-${lower(var.project_name)}-${lower(var.env_name)}-private"
  image_id               = module.get_ami.ami.id
  instance_type          = var.instance_type
  user_data              = var.instance_user_data == null ? null : base64encode(format("%s%s", local.init_user_data, var.instance_user_data))
}