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

module "get_subnets" {
  source              = "../../utils/get_subnets"
  subnets_name_filter = var.subnets_name_filter
  vpc_is_default      = var.vpc_is_default
}

locals {
  def_cidr      = ["0.0.0.0/0"]
  has_cidr      = length(var.alb_ingress_cidrs) > 0
  ingress_cidrs = local.has_cidr ? var.alb_ingress_cidrs : local.def_cidr
}

module "sg_alb_in_out" {
  source         = "../../utils/mk_sg"
  name           = "secg-${var.application_code}-${var.env_name}-private-alb"
  default_vpc_id = module.get_subnets.default_vpc.id
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
  tags = module.get_tags.tags
}

module "sg_ec2_in" {
  source         = "../../utils/mk_sg"
  name           = "secg-${var.application_code}-${var.env_name}-private-ec2"
  default_vpc_id = module.get_subnets.default_vpc.id
  ingress_rules = [{
    from_port          = var.alb_egress_port
    to_port            = var.alb_egress_port
    protocol           = "tcp"
    cidr_blocks        = []
    ipv6_cidr_blocks   = []
    security_group_ids = [module.sg_alb_in_out.security_group.id]
  }]
  tags = module.get_tags.tags
}

resource "aws_lb" "this" {
  name               = "alb-${var.application_code}-${var.env_name}-private"
  load_balancer_type = "application"
  internal           = true
  subnets            = module.get_subnets.ids
  security_groups    = [module.sg_alb_in_out.security_group.id]
  tags               = module.get_tags.tags
}

data "aws_acm_certificate" "this" {
  domain      = var.alb_domain_name
  most_recent = true
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.alb_ingress_port
  protocol          = "HTTPS"
  certificate_arn   = data.aws_acm_certificate.this.arn
  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_lb_target_group" "this" {
  name     = "${lower(var.application_code)}-${lower(var.project_name)}-${lower(var.env_name)}-alb-sample"
  port     = var.alb_egress_port
  protocol = "HTTPS"
  vpc_id   = module.get_subnets.default_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTPS"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  tags = module.get_tags.tags
}

resource "aws_lb_listener_rule" "this" {
  listener_arn = aws_lb_listener.this.arn
  priority     = 100
  condition {
    path_pattern {
      values = ["*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
