
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
locals {
  ctags = {
    for vt in var.resource_tags : vt.key => vt.constant
    if vt["is_constant"]
  }
  atags = {
    for vt in var.resource_tags : vt.key => lower(var.application_code)
    if vt.is_application_code
  }
  etags = {
    for vt in var.resource_tags : vt.key => lower(var.env_name)
    if vt.is_env_name
  }
  ptags = {
    for vt in var.resource_tags : vt.key => lower(var.project_name)
    if vt.is_project_name
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

module "get_ami" {
  source = "../../utils/get_ami"
  ami_name_regex = var.ami_name_regex
  ami_owner = var.ami_owner
}

resource "aws_security_group" "this" {
  name = "${lower(var.application_code)}-${lower(var.project_name)}-${lower(var.env_name)}-alb-asg-sample-asg-${data.aws_region.current.name}"
}

resource "aws_security_group_rule" "allow_server_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.this.id

  from_port   = var.server_port
  to_port     = var.server_port
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_all_asg_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.this.id

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_launch_template" "this" {
  update_default_version = true
  name                   = "${lower(var.application_code)}-${lower(var.project_name)}-${lower(var.env_name)}-alb-asg-sample-${data.aws_region.current.name}"
  image_id               = module.get_ami.ami.id
  instance_type          = var.instance_type
  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    server_port = var.server_port
  }))
  vpc_security_group_ids = [aws_security_group.this.id]
  key_name               = var.instance_has_ssh ? var.instance_key_name : null
  tag_specifications {
    tags = merge(
      {
        Name = "${lower(var.application_code)}-${lower(var.project_name)}-${lower(var.env_name)}-alb-asg-sample-${data.aws_region.current.name}"
      },
      local.ctags, local.atags, local.etags, local.ptags
    )
    resource_type = "instance"
  }
  tags = merge(
    local.ctags, local.atags, local.etags, local.ptags
  )
}

resource "aws_autoscaling_group" "asg" {

  launch_template {
    id = aws_launch_template.this.id
  }
  vpc_zone_identifier = data.aws_subnets.default.ids
  target_group_arns    = [aws_lb_target_group.this.arn]
  health_check_type    = "ELB"

  min_size = var.min_size
  max_size = var.max_size

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "alb" {
  name = "${lower(var.application_code)}-${lower(var.project_name)}-${lower(var.env_name)}-alb-asg-sample-alb-${data.aws_region.current.name}"
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.alb.id

  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_all_alb_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.alb.id

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_lb" "this" {
  name               = "${lower(var.application_code)}-${lower(var.project_name)}-${lower(var.env_name)}-alb-sample"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"
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
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
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
