
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

resource "aws_iam_service_linked_role" "role_for_asg" {
  aws_service_name = "autoscaling.amazonaws.com"
  custom_suffix    = lower(var.application_code)
  description      = "Allows EC2 Auto Scaling to use or manage AWS services and resources on your behalf."
}

# Creates a KMS Customer Managed Key including rotation, related Alias and key policy.
# The key policy grants Encrypt/Decrypt/GenerateKeys...
# to the root account, to S3 service, Lambda, Cloudwatch Events and ASG.

resource "aws_kms_key" "kms_key_for_infra" {
  # TODO DeletionPolicy: Retain
  description = "KMS symmetric Key used for EBS, RDS and S3 encryption"
  enable_key_rotation = true
  tags = merge(var.default_tags,
    {
      "corp:billing": lower(var.application_code)
    })
}

resource "aws_kms_alias" "kms_key_for_infra_alias" {
  target_key_id = aws_kms_key.kms_key_for_infra.id
  name = "alias/kms-key-${lower(var.application_code)}-dev-${data.aws_region.current.name}"
}

resource "aws_kms_key_policy" "kms_key_for_infra" {
  key_id = aws_kms_key.kms_key_for_infra.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "keypolicy",
    "Statement" : [
      {
        "Sid" : "keyAdmin",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action" : "kms:*",
        "Resource" : "*"
      },
      {
        "Sid" : "S3CryptDecrypt",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "s3.amazonaws.com"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "LambdaCryptDecrypt",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "EventsCryptDecrypt",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "events.amazonaws.com"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "ASGCryptDecrypt",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/${aws_iam_service_linked_role.role_for_asg.name}"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "ASG Allow attachment of persistent resources",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/${aws_iam_service_linked_role.role_for_asg.name}"
        },
        "Action" : "kms:CreateGrant",
        "Resource" : "*",
        "Condition" : {
          "Bool" : {
            "kms:GrantIsForAWSResource" : "true"
          }
        }
      },
      {
        "Sid" : "OpenSearchCryptDecrypt",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "*"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ],
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "kms:CallerAccount" : "${data.aws_caller_identity.current.account_id}",
            "kms:ViaService" : "es.${data.aws_region.current.name}.amazonaws.com"
          }
        }
      },
      {
        "Sid" : "OpenSearchList",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "es.amazonaws.com"
        },
        "Action" : [
          "kms:Describe*",
          "kms:Get*",
          "kms:List*"
        ],
        "Resource" : "*"
      }
    ]
  })
}
