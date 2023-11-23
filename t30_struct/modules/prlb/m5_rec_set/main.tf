terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.22"
    }
  }
}

data "aws_route53_zone" "this" {
  name         = var.hosted_zone_name
  private_zone = var.hosted_zone_is_private
}

resource "aws_route53_record" "this" {
  name    = var.alb_domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.this.zone_id
  alias {
    evaluate_target_health = false
    name                   = var.alb_domain_name
    zone_id                = var.alb_zone_id
  }
}