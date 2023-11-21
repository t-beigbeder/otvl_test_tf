# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "application_code" {
  description = "A unique code for the application"
  type        = string
}

variable "env_name" {
  description = "A unique environment name in this account"
  type        = string
}

variable "project_name" {
  description = "A unique project name in this account"
  type        = string
}

variable "resource_tags" {
  description = "Tags that apply to all resources"
  type        = list(object({
    key = string
    is_constant = bool
    constant = optional(string)
    is_application_code = bool
    is_env_name = bool
    is_project_name = bool
  }))
}

variable "vpc_is_default" {
  description = "Use default VPC, else only one VPC should be available"
  type        = bool
}

variable "role_ec2_to_s3_kms_efs_arn" {
  description = "The ARN of the role to enable S3 instances to access infra"
  type = string
}

variable "kms_key_for_infra_arn" {
  description = "ARN of the KMS key created for infrastructure services"
  type = string
}

variable "subnets_name_filter" {
  description = "Name filter to get the subnets list (where ASG resources are launched)"
  type        = string
}

variable "ec2_mandatory_sg_name" {
  description = "The name or empty of a role that applies to all EC2 instances"
  type        = string
}

variable "alb_private_ec2_security_group_id" {
  description = "The id of the security group enabling ALB egress to EC2 ingress"
  type = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------
