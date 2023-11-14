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

variable "app_has_infra_bucket" {
  description = "Whether an application S3 bucket for infra code has to be created"
  type = bool
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

variable "ec2_mandatory_policy_name" {
  description = "The name or empty of a policy that applies to all EC2 instances"
  type        = string
}

variable "ec2_admin_instance_type" {
  description = "The type of EC2 Admin Instances to run (e.g. t3.micro)"
  type        = string
}

variable "ec2_lb_instance_ami_name_regex" {
  description = "The name regex for filtering AMI of EC2 ALB ASG Instances to run (e.g. amzn2-ami-amd)"
  type        = string
}

variable "ec2_lb_instance_ami_owner" {
  description = "The owner name or empty for filtering AMI of EC2 ALB ASG Instances to run (e.g. 099720109477)"
  type        = string
}

variable "ec2_lb_instance_type" {
  description = "The type of EC2 ALB ASG Instances to run (e.g. t3.micro)"
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "ec2_lb_instance_user_data" {
  description = "User data to be passed to the instance"
  type        = string
  default     = null
}

variable "ec2_lb_instance_ssh_key_name" {
  description = "The key name for ssh to EC2 Instances in the ASG or empty if no ssh"
  type        = string
  default     = ""
}

variable "min_size" {
  description = "The minimum number of EC2 Instances in the ASG"
  type        = number
  default = 1
}

variable "max_size" {
  description = "The maximum number of EC2 Instances in the ASG"
  type        = number
  default = 2
}
