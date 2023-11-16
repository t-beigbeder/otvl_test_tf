terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.22"
    }
  }
}

module "get_subnets" {
  source              = "../../utils/get_subnets"
  subnets_name_filter = var.subnets_name_filter
}

locals {
  def_cidr      = ["0.0.0.0/0"]
  has_cidr      = length(var.alb_ingress_cidrs) > 0
  ingress_cidrs = local.has_cidr ? var.alb_ingress_cidrs : local.def_cidr
}

module "sg_alb_in" {
  source = "../../utils/mk_sg"
  name   = "secg-${var.application_code}-${var.env_name}-private-alb"
  ingress_rules = [{
    from_port          = var.alb_ingress_port
    to_port            = var.alb_ingress_port
    protocol           = "tcp"
    cidr_blocks        = local.ingress_cidrs
    ipv6_cidr_blocks   = []
    security_group_ids = []
  }]
  egress_rules = [
    {
      from_port          = var.alb_ingress_port
      to_port            = var.alb_ingress_port
      protocol           = "tcp"
      cidr_blocks        = module.get_subnets.cidrs
      ipv6_cidr_blocks   = []
      security_group_ids = []
    },
    {
      from_port          = var.alb_egress_port
      to_port            = var.alb_egress_port
      protocol           = "tcp"
      cidr_blocks        = module.get_subnets.cidrs
      ipv6_cidr_blocks   = []
      security_group_ids = []
    }
  ]
}