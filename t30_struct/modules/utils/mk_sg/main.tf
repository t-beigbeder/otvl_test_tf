terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.22"
    }
  }
}

locals {
  aa_egresses = [
    {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      ipv6_cidr_blocks = null
      security_group_ids = null
    },
    {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = null
      ipv6_cidr_blocks = ["::/0"]
      security_group_ids = null
    }
  ]
  egresses = var.egress_allow_all ? tolist( local.aa_egresses) : var.egress_rules
}

/*
resource "aws_security_group_rule" "egress" {
  count = local.egress_rule == null ? 0 : 1
  type              = "egress"
  security_group_id = aws_security_group.this.id
  from_port         = local.egress_rule.from_port
  to_port         = local.egress_rule.to_port
  protocol          = local.egress_rule.protocol
  cidr_blocks = local.egress_rule.cidr_blocks
  ipv6_cidr_blocks = local.egress_rule.ipv6_cidr_blocks
  source_security_group_id = local.egress_rule.source_security_group_id
}
*/

/*
resource "aws_security_group_rule" "ingresses" {
  count = length(var.ingress_rules)
  type              = "ingress"
  security_group_id = aws_security_group.this.id
  from_port         = var.ingress_rules[count.index].from_port
  to_port         = var.ingress_rules[count.index].to_port
  protocol          = var.ingress_rules[count.index].protocol
  cidr_blocks = var.ingress_rules[count.index].cidr_blocks
  ipv6_cidr_blocks = var.ingress_rules[count.index].ipv6_cidr_blocks
  source_security_group_id = var.ingress_rules[count.index].source_security_group_id
}
*/

resource "aws_security_group" "this" {
  name = var.name
  description = var.description
  tags = var.tags
  dynamic "egress" {
    for_each = local.egresses
    content {
      from_port         = egress.value["from_port"]
      to_port         = egress.value["to_port"]
      protocol         = egress.value["protocol"]
      cidr_blocks         = egress.value["cidr_blocks"]
      ipv6_cidr_blocks         = egress.value["ipv6_cidr_blocks"]
      security_groups         = egress.value["security_group_ids"]
    }
  }
}
