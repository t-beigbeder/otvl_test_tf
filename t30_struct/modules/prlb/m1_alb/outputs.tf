output "alb_target_group" {
  value = aws_lb_target_group.this
  description = "The ALB target group created by this module (for use by the ASG)"
}

output "alb_private_ec2_security_group" {
  value = module.sg_ec2_in.security_group
  description = "The security group enabling ALB egress to EC2 ingress"
}

output "alb_zone_id" {
  value = aws_lb.this.zone_id
  description = "The canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record)"
}

output "alb_dns_name" {
  value = aws_lb.this.zone_id
  description = "The DNS name of the load balancer"
}
