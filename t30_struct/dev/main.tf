provider "aws" {
  region = "eu-west-3"
}

terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version     = "5.23.1"
    }
  }

  backend "s3" {
    bucket         = "default-tf-bucket"
    key            = "t30/dev/terraform.tfstate"
    region         = "eu-west-3"
    dynamodb_table = "default-tf-dynamo-table"
    encrypt        = true
  }

}

resource "aws_iam_service_linked_role" "aws_service_role_for_asg" {
  aws_service_name = "autoscaling.amazonaws.com"
  custom_suffix    = "t30"
  description      = "Allows EC2 Auto Scaling to use or manage AWS services and resources on your behalf."
}
