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

module "get_tags" {
  source           = "../../utils/get_tags"
  application_code = var.application_code
  env_name         = var.env_name
  project_name     = var.project_name
  resource_tags    = var.resource_tags
}

module "get_subnets" {
  source = "../../utils/get_subnets"
  subnets_name_filter = var.subnets_name_filter
  vpc_is_default = var.vpc_is_default
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

data "aws_security_group" "ec2_mandatory" {
  name = var.ec2_mandatory_sg_name
}

resource "aws_launch_template" "this" {
  update_default_version = true
  name                   = "lt-${lower(var.application_code)}-${lower(var.project_name)}-${lower(var.env_name)}-private"
  image_id               = module.get_ami.ami.id
  instance_type          = var.instance_type
  user_data              = var.instance_user_data == null ? null : base64encode(format("#!/bin/bash\n%s%s", local.init_user_data, var.instance_user_data))
  iam_instance_profile {
    arn = aws_iam_instance_profile.this.arn
  }
  vpc_security_group_ids = [
    var.alb_private_ec2_security_group_id,
    data.aws_security_group.ec2_mandatory.id
  ]
  key_name = var.instance_ssh_key_name == null ? null : var.instance_ssh_key_name
  block_device_mappings {
    device_name = "/dev/sdb"
    ebs {
      volume_type = var.ebs_volume_type
      volume_size = var.ebs_volume_size
      delete_on_termination = "true"
      encrypted = "true"
      kms_key_id = var.kms_key_for_infra_arn
    }
  }
  tag_specifications {
    tags = merge(
      {
        Name = "asg-ec2-${lower(var.application_code)}-${lower(var.env_name)}-private"
      },
      module.get_tags.tags
    )
    resource_type = "instance"
  }
  tags = module.get_tags.tags
}

resource "aws_autoscaling_group" "this" {
  name = "asg-${lower(var.application_code)}-${lower(var.env_name)}-private"
  launch_template {
    id = aws_launch_template.this.id
  }
  vpc_zone_identifier = module.get_subnets.ids
  target_group_arns    = [var.alb_target_group_arn]

  health_check_type    = "ELB"
  termination_policies = ["NewestInstance"]
  metrics_granularity = "1Minute"
  min_size = var.min_size
  max_size = var.max_size
  desired_capacity = var.min_size

  instance_refresh {
    strategy = "Rolling"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "scale_up" {
  autoscaling_group_name = aws_autoscaling_group.this.name
  name = "asg-scaleup-${lower(var.application_code)}-${lower(var.env_name)}-private"
  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = "+1"
  cooldown = 300
}

resource "aws_autoscaling_policy" "scale_down" {
  autoscaling_group_name = aws_autoscaling_group.this.name
  name = "asg-scaledown-${lower(var.application_code)}-${lower(var.env_name)}-private"
  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = "-1"
  cooldown = 300
}