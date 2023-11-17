output "alb_target_group" {
  value = aws_lb_target_group.this
  description = "The ALB target group created by this module (for use by the ASG)"
}