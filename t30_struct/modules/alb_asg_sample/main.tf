
terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.22"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
locals {
  ctags = {
    for vt in var.resource_tags : vt.key => vt.constant
    if vt["is_constant"]
  }
  atags = {
    for vt in var.resource_tags : vt.key => lower(var.application_code)
    if vt.is_application_code
  }
  etags = {
    for vt in var.resource_tags : vt.key => lower(var.env_name)
    if vt.is_env_name
  }
  ptags = {
    for vt in var.resource_tags : vt.key => lower(var.project_name)
    if vt.is_project_name
  }
}

data "aws_ami" "debian" {
  most_recent = true
  name_regex  = "debian-12"
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  owners = ["136693071363"]
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_launch_template" "this" {
  image_id      = data.aws_ami.debian.id
  instance_type = var.instance_type
  name          = "s3-${lower(var.application_code)}-${lower(var.project_name)}-${lower(var.env_name)}-alb-asg-sample-${data.aws_region.current.name}"
  tag_specifications {
    tags = merge(
      {
        Name = "s3-${lower(var.application_code)}-${lower(var.project_name)}-${lower(var.env_name)}-alb-asg-sample-${data.aws_region.current.name}"
      },
      local.ctags, local.atags, local.etags, local.ptags
    )
    resource_type = "instance"
  }
  tags = merge(
    local.ctags, local.atags, local.etags, local.ptags
  )
}

resource "aws_autoscaling_group" "asg" {

  launch_template {
    id = aws_launch_template.this.id
    version = "$Latest"
  }
  vpc_zone_identifier = data.aws_subnets.default.ids

  min_size = var.min_size
  max_size = var.max_size

  lifecycle {
    create_before_destroy = true
  }
}
