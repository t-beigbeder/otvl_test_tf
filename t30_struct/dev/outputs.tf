output "role_for_asg_name" {
  value       = module.prereqs.role_for_asg_name
  description = "The name of the role created for the ASG"
}

output "kms_key_for_infra_value" {
  value = module.prereqs.kms_key_for_infra
  description = "The KMS key created for infrastructure services"
}
