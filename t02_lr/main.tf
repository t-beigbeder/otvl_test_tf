provider "aws" {
  region = "eu-west-3"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.23.1"
    }
  }
}

resource "aws_iam_service_linked_role" "aws_service_role_for_asg" {
  aws_service_name = "autoscaling.amazonaws.com"
  custom_suffix = "t02l"
  description = "Allows EC2 Auto Scaling to use or manage AWS services and resources on your behalf."
}

data "aws_iam_policy" "administrator_access_policy" {
  arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

data "aws_iam_policy" "policy_sample_ec2_permissions" {
  name        = "policy-sample-ec2-permissions"
}

resource "aws_iam_role" "EC2AdminRole" {
  name = "role-t02l-appname-dev-DevAdmin-ec2admin"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  managed_policy_arns = [
  "${data.aws_iam_policy.administrator_access_policy.arn}",
    "${data.aws_iam_policy.policy_sample_ec2_permissions.arn}"
  ]
}