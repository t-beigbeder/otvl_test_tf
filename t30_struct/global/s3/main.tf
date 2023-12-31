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
    key            = "t30/global/s3/terraform.tfstate"
    region         = "eu-west-3"
    dynamodb_table = "default-tf-dynamo-table"
    encrypt        = true
  }

}

provider "aws" {
  region = "eu-west-3"
}

locals {
  ctags = {
    for vt in var.resource_tags : vt.key => vt.constant
    if vt["is_constant"]
  }
  atags = {
    for vt in var.resource_tags : vt.key => lower(var.application_code)
    if vt.is_application_code
  }
}

resource "aws_s3_bucket" "terraform_state" {

  bucket = var.bucket_name

  // This is only here so we can destroy the bucket as part of automated tests. You should not copy this for production
  // usage
  force_destroy = true

  tags = merge(local.ctags, local.atags)

}

# Enable versioning so you can see the full revision history of your
# state files
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption by default
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Explicitly block all public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
