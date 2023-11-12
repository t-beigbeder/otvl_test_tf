
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

data "aws_iam_policy" "AdministratorAccess" {
  arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

data "aws_iam_policy" "ec2_perm" {
  arn = "arn:aws:iam::674493391874:policy/policy-sample-ec2-permissions"
}

data "aws_ami" "this" {
  most_recent = true
  name_regex  = "debian-12"
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  owners = ["136693071363"] # https://wiki.debian.org/Cloud/AmazonEC2Image/Bookworm
}

resource "aws_iam_role" "this" {
  name = "s3-${lower(var.application_code)}-${lower(var.project_name)}-${lower(var.env_name)}-ec2admin-${data.aws_region.current.name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  managed_policy_arns = [
    data.aws_iam_policy.AdministratorAccess.arn,
    data.aws_iam_policy.ec2_perm.arn
  ]
}

resource "aws_instance" "this" {
  ami = data.aws_ami.this.id
  instance_type = var.instance_type
  tags = merge({
    Name = "s3-${lower(var.application_code)}-${lower(var.project_name)}-${lower(var.env_name)}-ec2admin-${data.aws_region.current.name}"
    },
    local.ctags, local.atags, local.etags, local.ptags
  )
}
