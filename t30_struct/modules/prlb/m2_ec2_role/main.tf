terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.22"
    }
  }
}

data "aws_iam_policy" "AmazonEC2RoleforSSM" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

data "aws_iam_policy" "AmazonS3FullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

data "aws_iam_policy" "AmazonElasticFileSystemFullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
}

locals {
  fixed_policies = [
    data.aws_iam_policy.AmazonEC2RoleforSSM.arn,
    data.aws_iam_policy.AmazonS3FullAccess.arn,
    data.aws_iam_policy.AmazonElasticFileSystemFullAccess.arn
  ]
}

data "aws_iam_policy" "ec2_mandatory_policy" {
  count = var.ec2_mandatory_policy_name == "" ? 0 : 1
  name  = var.ec2_mandatory_policy_name
}

resource "aws_iam_role" "this" {
  name = "roleEC2toS3andKMSandEFS-${lower(var.application_code)}-${lower(var.env_name)}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = ["ec2.amazonaws.com"]
        }
      }
    ]
  })
  inline_policy {
    name = "s3kmsKey"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:DescribeKey"
          ]
          Resource = var.kms_key_for_infra_arn
        },
      ]
    })
  }
  managed_policy_arns = concat(local.fixed_policies, data.aws_iam_policy.ec2_mandatory_policy[*].arn)
}