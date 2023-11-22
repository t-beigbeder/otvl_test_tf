output "role_for_asg_name" {
  value       = aws_iam_service_linked_role.role_for_asg.name
  description = "The name of the role created for the ASG"
}

output "kms_key_for_infra" {
  value = aws_kms_key.kms_key_for_infra
  description = "The KMS key created for infrastructure services"
}

output "kms_alias_for_infra" {
  value = aws_kms_alias.kms_alias_for_infra
  description = "The alias of the KMS key created for infrastructure services"
}

output "app_infra_bucket_name" {
  value = var.app_has_infra_bucket ? one(aws_s3_bucket.app_infra_bucket[*]).bucket : ""
  description = "The name of application infra S3 bucket"
}
