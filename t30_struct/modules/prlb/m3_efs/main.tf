terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.22"
    }
  }
}

module "get_tags" {
  source           = "../../utils/get_tags"
  application_code = var.application_code
  env_name         = var.env_name
  project_name     = var.project_name
  resource_tags    = var.resource_tags
}

resource "aws_efs_file_system" "this" {
  encrypted  = true
  kms_key_id = var.kms_key_for_infra_arn
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  lifecycle_policy {
    transition_to_primary_storage_class = "AFTER_1_ACCESS"
  }
  tags = module.get_tags.tags
}

resource "aws_efs_backup_policy" "this" {
  file_system_id = aws_efs_file_system.this.id
  backup_policy {
    status = "ENABLED"
  }
}

data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [var.role_ec2_to_s3_kms_efs_arn]
    }

    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite",
      "elasticfilesystem:ClientRootAccess",
    ]

    resources = [aws_efs_file_system.this.arn]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["true"]
    }
  }
}

resource "aws_efs_file_system_policy" "this" {
  file_system_id = aws_efs_file_system.this.id
  bypass_policy_lockout_safety_check = false
  policy = data.aws_iam_policy_document.this.json
}
