output "role_ec2_to_s3_kms_efs_arn" {
  value = aws_iam_role.this.arn
  description = "The ARN of the role to enable S3 instances to access infra"
}
