provider "aws" {
  region = "eu-west-3"
}

terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version     = "5.24.0"
    }
  }

  backend "s3" {
    bucket         = "default-tf-bucket"
    key            = "t30/global/for_tests/terraform.tfstate"
    region         = "eu-west-3"
    dynamodb_table = "default-tf-dynamo-table"
    encrypt        = true
  }

}

resource "aws_iam_policy" "policy" {
  name        = "policy-sample-ec2-permissions"
  description = "Does not play any role, just to check it can be referenced by roles"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })

}
