terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.22"
    }
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnet" "all" {
  count = length(data.aws_subnets.all.ids)
  id    = data.aws_subnets.all.ids[count.index]
}

locals {
  ids = [
    for v in data.aws_subnet.all : v.id
    if strcontains(lookup(v.tags, "Name", ""), var.subnets_name_filter)
  ]
  cidrs = [
    for v in data.aws_subnet.all : v.cidr_block
    if strcontains(lookup(v.tags, "Name", ""), var.subnets_name_filter)
  ]
  list = [
    for v in data.aws_subnet.all : v
    if strcontains(lookup(v.tags, "Name", ""), var.subnets_name_filter)
  ]
  byid = {
    for v in data.aws_subnet.all : v.id => v
    if strcontains(lookup(v.tags, "Name", ""), var.subnets_name_filter)
  }
  byname = {
    for v in data.aws_subnet.all : v.tags["Name"] => v
    if strcontains(lookup(v.tags, "Name", ""), var.subnets_name_filter)
  }
}
