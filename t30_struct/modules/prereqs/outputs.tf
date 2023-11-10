output "role_for_asg_name" {
  value       = aws_iam_service_linked_role.role_for_asg.name
  description = "The name of the role created for the ASG"
}

output "kms_key_for_infra" {
  value = aws_kms_key.kms_key_for_infra
  description = "The KMS key created for infrastructure services"
}