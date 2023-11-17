output "alb_target_group" {
  value = aws_lb_target_group.this
  description = "The ALB target group created by this module (for use by the ASG)"
}

output "alb_private_ec2_security_group" {
  value = module.sg_ec2_in.security_group
  description = "The security group enabling ALB egress to EC2 ingress"
}
