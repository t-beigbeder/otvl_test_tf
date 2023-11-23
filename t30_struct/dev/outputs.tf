output "kms_key_for_infra_arn" {
  value = module.prereqs.kms_key_for_infra.arn
  description = "The ARN of the KMS key created for infrastructure services"
}

output "kms_alias_for_infra_name" {
  value = module.prereqs.kms_alias_for_infra.name
  description = "The alias name of the KMS key created for infrastructure services"
}

output "app_infra_bucket_name" {
  value = module.prereqs.app_infra_bucket_name
  description = "The name of application infra S3 bucket"
}
