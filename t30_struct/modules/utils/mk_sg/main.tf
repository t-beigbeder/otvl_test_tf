terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.22"
    }
  }
}

resource "aws_security_group" "this" {
  name = var.name
  description = var.description
}

locals {
  egress_rule = var.egress_allow_all ? {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    source_security_group_id = null

  } : var.egress_rule
}

resource "aws_security_group_rule" "egress" {
  count = local.egress_rule == null ? 0 : 1
  type              = "egress"
  security_group_id = aws_security_group.this.id
  from_port         = local.egress_rule.from_port
  to_port         = local.egress_rule.to_port
  protocol          = local.egress_rule.protocol
  cidr_blocks = local.egress_rule.cidr_blocks
}
