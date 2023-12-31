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
  type        = bool
}

variable "resource_tags" {
  description = "Tags that apply to all resources"
  type = list(object({
    key                 = string
    is_constant         = bool
    constant            = optional(string)
    is_application_code = bool
    is_env_name         = bool
    is_project_name     = bool
  }))
}

variable "hosted_zone_name" {
  description = "The DNS domain of the hosted zone of the account"
  type        = string
}

variable "hosted_zone_is_private" {
  description = "Private status of the hosted zone of the account"
  type        = bool
}

variable "alb_domain_name" {
  description = "The DNS domain to reach the ALB (TLS certificate subject)"
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

variable "ec2_mandatory_policy_name" {
  description = "The name or empty of a policy that applies to all EC2 instances"
  type        = string
}

variable "ec2_mandatory_sg_name" {
  description = "The name or empty of a role that applies to all EC2 instances"
  type        = string
}

variable "asg_subnets_name_filter" {
  description = "Name filter to get the subnets list to launch ASG resources in"
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "vpc_is_default" {
  description = "Use default VPC, else only one VPC should be available"
  type        = bool
  default     = false
}

variable "alb_is_internal" {
  description = "Keep ALB access internal, set to false to test public access"
  type        = bool
  default     = true
}

variable "alb_ingress_cidrs" {
  description = "The list of CIDR ranges to enable as ingress on the ALB, if empty, all IPs are authorized"
  type        = list(string)
  default     = []
}

variable "alb_ingress_port" {
  description = "The port to enable as ingress on the ALB"
  type        = number
  default     = 443
}

variable "alb_egress_port" {
  description = "The port to enable as egress on the ALB"
  type        = number
  default     = 443
}

variable "ec2_lb_instance_user_data" {
  description = "User data to be passed to the instance"
  type        = string
  default     = null
}

variable "ebs_volume_type" {
  description = "Type of the volume for EC2 instances EBS"
  type        = string
  default     = "gp2"
}

variable "ebs_volume_size" {
  description = "Size of the volume for EC2 instances EBS"
  type        = number
  default     = 100
}

variable "ec2_lb_instance_ssh_key_name" {
  description = "The key name for ssh to EC2 Instances in the ASG or empty if no ssh"
  type        = string
  default     = ""
}

variable "min_size" {
  description = "The minimum number of EC2 Instances in the ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "The maximum number of EC2 Instances in the ASG"
  type        = number
  default     = 2
}
