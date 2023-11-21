
output "efs_mount_target_security_group" {
  value = module.sg_efs_mount_target.security_group
  description = "The security group enabling EFS ingress from ASG EC2"
}
